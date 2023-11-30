//
//  ExpenseListViewModel.swift
//  FairShare
//
//  Created by Cole Weinman on 10/13/23.
//

import Foundation
import FirebaseFirestore

class ExpenseListViewModel: ObservableObject {
    @Published var expenses: [Expense]?
    
    private var listener: ListenerRegistration?
    
    private var db = Firestore.firestore()
    
    func add(expense: Expense) -> String? {
        do {
            let docRef = try db.collection("expenses").addDocument(from: expense)
            return docRef.documentID
        } catch {
            return nil
        }
    }
    
    func update(expense: Expense) -> Bool {
        do {
            guard let expenseId = expense.id else {
                return false
            }
            try db.collection("expenses").document(expenseId).setData(from: expense)
            return true
        } catch {
            return false
        }
    }
    
    func remove(expenseId: String) {
        db.collection("expenses").document(expenseId).delete()
    }
    
    func fetchData(uid: String) {
        db.collection("expenses").whereField("involvedUserIds", arrayContains: uid).order(by: "date", descending: true)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                do {
                    let expenses = try documents.map { doc in
                        return try doc.data(as: Expense.self)
                    }
                    self.expenses = expenses
                } catch {
                    self.expenses = []
                }
            }
    }
    
    func fetchData(uid: String, startDate: Date?, endDate: Date?, minAmount: Double?, maxAmount: Double?, sortBy: Sort?, sortOrder: Bool?) {
        listener?.remove()
        let expensesRef = db.collection("expenses")
        var query = expensesRef.whereField("involvedUserIds", arrayContains: uid)
        if var startDate = startDate, var endDate = endDate {
            startDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: startDate)!
            endDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: endDate)!
            query = query
                .whereField("date", isGreaterThanOrEqualTo: startDate)
                .whereField("date", isLessThanOrEqualTo: endDate)
        }
        if let minAmount = minAmount, let maxAmount = maxAmount {
            query = query
                .whereField("totalAmount", isGreaterThanOrEqualTo: minAmount)
                .whereField("totalAmount", isLessThanOrEqualTo: maxAmount)
        }
        if let sortBy = sortBy, let sortOrder = sortOrder {
            switch sortBy {
                case .date:
                    query = query
                        .order(by: "date", descending: !sortOrder)
                        .order(by: "totalAmount", descending: true)
                case .amount:
                    query = query
                        .order(by: "totalAmount", descending: !sortOrder)
                        .order(by: "date", descending: true)
            }
        }
        listener = query.addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            do {
                print("update")
                let expenses = try documents.map { doc in
                    return try doc.data(as: Expense.self)
                }
                self.expenses = expenses
            } catch {
                self.expenses = []
            }
        }
    }
}
