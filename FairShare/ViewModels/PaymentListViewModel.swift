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
    
    func fetchData(uid: String, startDate: Date?, endDate: Date?, minAmount: Double?, maxAmount: Double?, involved: [String]?, sortBy: Sort?, sortOrder: Bool?) {
        let paymentsRef = db.collection("payments")
        var query = paymentsRef.whereField("involvedUserIds", arrayContains: uid)
        if let startDate = startDate, let endDate = endDate {
            query = query
                .whereField("date", isGreaterThanOrEqualTo: startDate)
                .whereField("date", isLessThanOrEqualTo: endDate)
        }
        if let minAmount = minAmount, let maxAmount = maxAmount {
            query = query
                .whereField("amount", isGreaterThanOrEqualTo: minAmount)
                .whereField("amount", isLessThanOrEqualTo: maxAmount)
        }
        if let involved = involved {
            query = query.whereField("involved", arrayContainsAny: involved)
        }
        
        if let sortBy = sortBy, let sortOrder = sortOrder {
            switch sortBy {
                case .date:
                    query = query.order(by: "date", descending: !sortOrder)
                case .amount:
                    query = query.order(by: "amount", descending: !sortOrder)
            }
        }
        
        var _ = query.addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            do {
                let payments = try documents.map { doc in
                    return try doc.data(as: Payment.self)
                }
                self.payments = payments
            } catch {
                self.payments = []
            }
        }
    }
}
