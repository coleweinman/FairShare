//
//  UserViewModel.swift
//  FairShare
//
//  Created by Cole Weinman on 10/13/23.
//

import Foundation
import FirebaseFirestore

class UserViewModel: ObservableObject {
    @Published var user: User?
    
    private var db = Firestore.firestore()
    
    func updateField(userId: String, field: String, value: Any) {
        db.collection("users").document(userId).updateData([field: value])
    }
    
    func fetchData(uid: String) {
        db.collection("users").document(uid)
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                do {
                    self.user = try document.data(as: User.self)
                } catch {
                    print("Error fetching document: \(error)")
                }
            }
    }
}
