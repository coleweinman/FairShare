//
//  UserViewModel.swift
//  FairShare
//
//  Created by Cole Weinman on 10/13/23.
//

import Foundation
import FirebaseFirestore
import FirebaseMessaging

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
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM registration token: \(token)")
                self.updateField(userId: uid, field: "fcmToken", value: token)
            }
        }
    }
}
