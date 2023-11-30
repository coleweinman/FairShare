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
    
    private var listener: ListenerRegistration?
    
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
                    self.payments = payments
                } catch {
                    self.payments = []
                }
            }
    }
    
    func fetchData(uid: String, startDate: Date?, endDate: Date?, minAmount: Double?, maxAmount: Double?, sortBy: Sort?, sortOrder: Bool?) {
        listener?.remove()
        let paymentsRef = db.collection("payments")
        var query = paymentsRef.whereField("involvedUserIds", arrayContains: uid)
        if var startDate = startDate, var endDate = endDate {
            startDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: startDate)!
            endDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: endDate)!
            query = query
                .whereField("date", isGreaterThanOrEqualTo: startDate)
                .whereField("date", isLessThanOrEqualTo: endDate)
        }
        if let minAmount = minAmount, let maxAmount = maxAmount {
            query = query
                .whereField("amount", isGreaterThanOrEqualTo: minAmount)
                .whereField("amount", isLessThanOrEqualTo: maxAmount)
        }
        if let sortBy = sortBy, let sortOrder = sortOrder {
            switch sortBy {
                case .date:
                    query = query
                        .order(by: "date", descending: !sortOrder)
                        .order(by: "amount", descending: true)
                case .amount:
                    query = query
                        .order(by: "amount", descending: !sortOrder)
                        .order(by: "date", descending: true)
            }
        }
        listener = query.addSnapshotListener { querySnapshot, error in
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
