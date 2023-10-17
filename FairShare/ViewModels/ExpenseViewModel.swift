//
//  ExpenseViewModel.swift
//  FairShare
//
//  Created by Cole Weinman on 10/13/23.
//

import Foundation
import FirebaseFirestore

class ExpenseViewModel: ObservableObject {
    @Published var expense: Expense?
        
        private var db = Firestore.firestore()
        
        func save() -> Bool {
            guard let expense = self.expense else {
                return false
            }
            if let expenseId = expense.id {
                do {
                    try db.collection("expenses").document(expenseId).setData(from: expense)
                    return true
                } catch {
                    print("Error saving expense  \(error)")
                }
            } else {
                do {
                    try db.collection("expenses").addDocument(from: expense)
                    return true
                } catch {
                    print("Error creating expense \(error)")
                }
            }
            return false
        }
        
        func fetchData(expenseId: String) {
            db.collection("expenses").document(expenseId)
                .addSnapshotListener { documentSnapshot, error in
                    guard let document = documentSnapshot else {
                        print("Error fetching document: \(error!)")
                        return
                    }
                    do {
                        self.expense = try document.data(as: Expense.self)
                    } catch {
                        print("Error fetching document: \(error)")
                    }
                }
        }
}

