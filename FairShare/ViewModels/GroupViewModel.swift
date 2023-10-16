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
    
    func fetchData(groupId: String) {
        db.collection("groups").document(groupId)
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                do {
                    self.group = try document.data(as: Group.self)
                } catch {
                    print("Error fetching document: \(error)")
                }
            }
    }
}
