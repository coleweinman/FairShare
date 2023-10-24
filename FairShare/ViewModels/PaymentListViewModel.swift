//
//  PaymentListViewModel.swift
//  FairShare
//
//  Created by boe jiden
//

import Foundation
import FirebaseFirestore

class PaymentListViewModel: ObservableObject {
    @Published var payments: [Payment]?
    
    private var db = Firestore.firestore()
    
    func add(payment: Payment) -> String? {
        do {
            let docRef = try db.collection("payments").addDocument(from: payment)
            return docRef.documentID
        } catch {
            return nil
        }
    }
    
    func update(payment: Payment) -> Bool {
        do {
            guard let paymentId = payment.id else {
                return false
            }
            try db.collection("payment").document(paymentId).setData(from: payment)
            return true
        } catch {
            return false
        }
    }
    
    func remove(paymentId: String) {
        db.collection("payments").document(paymentId).delete()
    }
    
    func fetchData(uid: String) {
        db.collection("payments").whereField("involvedUserIds", arrayContains: uid).order(by: "date", descending: true)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                do {
                    let payments = try documents.map { doc in
                        return try doc.data(as: Payment.self)
                    }
                    print(payments)
                    self.payments = payments
                } catch {
                    self.payments = []
                }
            }
    }
}
