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
                    print(newGroups)
                    print(documents.count)
                    self.groups = newGroups
                } catch {
                    print(error)
                    self.groups = []
                }
            }
    }
}
