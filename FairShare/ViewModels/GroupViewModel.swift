//
//  GroupViewModel.swift
//  FairShare
//
//  Created by Cole Weinman on 10/16/23.
//

import Foundation
import FirebaseFirestore

class GroupViewModel: ObservableObject {
    @Published var group: Group?
    
    private var db = Firestore.firestore()
    
    func save() -> Bool {
        guard let group = self.group else {
            return false
        }
        if let groupId = group.id {
            do {
                print("update")
                print(group.involvedUserIds)
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
        // TODO: This should be a cloud function instead
        do {
            guard let group = self.group else {
                return "Group not loaded"
            }
            guard email != "" else {
                return "No email specified"
            }
            let docs = try await db.collection("users").whereField("email", isEqualTo: email).getDocuments()
            guard docs.count > 0 else {
                return "No user found"
            }
            let firstDoc = docs.documents.first
            guard let userDoc = firstDoc else {
                return "Error inviting user"
            }
            let user = try userDoc.data(as: User.self)
            let basicUser = BasicUser(id: user.id!, name: user.name, profilePictureUrl: user.profilePictureUrl)
            guard !group.involvedUserIds.contains(basicUser.id) else {
                return "User already invited or member of group"
            }
            self.group?.invitedMembers.append(basicUser)
            self.group?.involvedUserIds.append(basicUser.id)
            return "Invited user successfully"
        } catch {
            return "Error inviting user"
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
