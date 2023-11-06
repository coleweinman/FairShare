//
//  GroupViewModel.swift
//  FairShare
//
//  Created by Cole Weinman on 10/16/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFunctions

class GroupViewModel: ObservableObject {
    @Published var group: Group?
    
    private var db = Firestore.firestore()
    private lazy var functions = Functions.functions()
    
    func save() -> Bool {
        guard let group = self.group else {
            return false
        }
        if let groupId = group.id {
            do {
                try db.collection("groups").document(groupId).setData(from: group)
                return true
            } catch {
                print("Error saving group \(error)")
            }
        } else {
            do {
                try db.collection("groups").addDocument(from: group)
                return true
            } catch {
                print("Error creating group \(error)")
            }
        }
        return false
    }
    
    func inviteUserByEmail(email: String) async -> String {
        guard self.group != nil else {
            return "Group not loaded"
        }
        guard email != "" else {
            return "No email specified"
        }
        let functionData = ["userEmail": email]
        do {
            let result = try await functions.httpsCallable("onFindUserRequest").call(functionData)
            if let data = result.data as? [String: Any],
               let user = data["user"] as? [String: Any],
               let userId = user["id"] as? String,
               let userName = user["name"] as? String,
               let userProfilePictureUrl = user["profilePictureUrl"] as? String?
            {
                let invitedUser = BasicUser(
                    id: userId, 
                    name: userName,
                    profilePictureUrl: userProfilePictureUrl != nil ? URL(string: userProfilePictureUrl!) : nil
                )
                await MainActor.run {
                    self.group!.invitedMembers.append(invitedUser)
                    self.group!.involvedUserIds.append(invitedUser.id)
                }
                return "User invited"
            } else if let data = result.data as? [String: Any], let message = data["message"] as? String {
                return message
            } else {
                print("Couldn't parse function response!")
                return "Error inviting user"
            }
        } catch {
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                    let code = FunctionsErrorCode(rawValue: error.code)
                    let message = error.localizedDescription
                    let details = error.userInfo[FunctionsErrorDetailsKey]
                    print("Cloud function error Code:\(code.debugDescription), Message:\(message), Details:\(details ?? "N/A")")
                    return message
                }
                return "Error inviting user"
            }
        }
    }
    
    func fetchData(groupId: String) {
        print("fetch data")
        db.collection("groups").document(groupId)
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                do {
                    print("group update")
                    self.group = try document.data(as: Group.self)
                    print(self.group?.name ?? "name of group")
                } catch {
                    print("Error fetching document: \(error)")
                }
            }
    }
}
