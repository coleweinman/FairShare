//
//  PaymentViewModel.swift
//  FairShare
//
//  Created by Melody Yin on 10/15/23.
//

import SwiftUI

import Foundation
import FirebaseFirestore

class PaymentViewModel: ObservableObject {
    @Published var payment: Payment?
        
        private var db = Firestore.firestore()
        
        func save() -> Bool {
            guard let payment = self.payment else {
                return false
            }
            if let paymentId = payment.id {
                do {
                    try db.collection("payments").document(paymentId).setData(from: payment)
                    return true
                } catch {
                    print("Error saving payment  \(error)")
                }
            } else {
                do {
                    try db.collection("payments").addDocument(from: payment)
                    return true
                } catch {
                    print("Error creating payment \(error)")
                }
            }
            return false
        }
        
        func fetchData(paymentId: String) {
            db.collection("payments").document(paymentId)
                .addSnapshotListener { documentSnapshot, error in
                    guard let document = documentSnapshot else {
                        print("Error fetching document: \(error!)")
                        return
                    }
                    do {
                        self.payment = try document.data(as: Payment.self)
                    } catch {
                        print("Error fetching document: \(error)")
                    }
                }
        }
    
    func deleteData(paymentId: String) {
        db.collection("payments").document(paymentId).delete() { err in
            if let error = err {
                print("Error removing payment: \(error)")
            } else {
                print("Payment successfully removed.")
            }
        }
    }
}
