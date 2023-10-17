//
//  ExpenseListViewModel.swift
//  FairShare
//
//  Created by Cole Weinman on 10/13/23.
//

import Foundation
import FirebaseFirestore

class ExpenseListViewModel: ObservableObject {
    @Published var expenses: [Expense]
    
    init() {
        self.expenses = []
    }
    
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
}
