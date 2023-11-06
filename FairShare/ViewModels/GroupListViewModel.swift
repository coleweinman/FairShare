//
//  GroupListViewModel.swift
//  FairShare
//
//  Created by Cole Weinman on 10/15/23.
//

import Foundation
import FirebaseFirestore

class GroupListViewModel: ObservableObject {
    @Published var groups: [Group]? = nil
    
    private var db = Firestore.firestore()
    
    func acceptInvitation(groupId: String, userId: String) -> String {
        let group = groups?.first(where: {g in g.id == groupId})
        guard var acceptGroup = group else {
            return "Error accepting invitation"
        }
        let basicUser = acceptGroup.invitedMembers.first(where: {u in u.id == userId})
        guard let user = basicUser else {
            return "Error accepting invitation"
        }
        acceptGroup.invitedMembers.removeAll(where: {u in u.id == user.id})
        acceptGroup.members.append(user)
        do {
            try db.collection("groups").document(groupId).setData(from: acceptGroup)
            return "Invitation accepted succesfully"
        } catch {
            return "Error accepting invitation"
        }
    }
    
    func fetchData(uid: String) {
        db.collection("groups").whereField("involvedUserIds", arrayContains: uid)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                do {
                    let newGroups = try documents.map { doc in
                        return try doc.data(as: Group.self)
                    }
                    self.groups = newGroups
                } catch {
                    print(error)
                    self.groups = []
                }
            }
    }
}
