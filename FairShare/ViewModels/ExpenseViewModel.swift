//
//  ExpenseViewModel.swift
//  FairShare
//
//  Created by Cole Weinman on 10/13/23.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

class ExpenseViewModel: ObservableObject {
    @Published var expense: Expense?
        
    private var db = Firestore.firestore()
    private var storage = Storage.storage()
        
    func save() -> String? {
        guard let expense = self.expense else {
            return nil
        }
        if let expenseId = expense.id {
            do {
                try db.collection("expenses").document(expenseId).setData(from: expense)
                return expenseId
            } catch {
                print("Error saving expense  \(error)")
            }
        } else {
            do {
                let docRef = try db.collection("expenses").addDocument(from: expense)
                return docRef.documentID
            } catch {
                print("Error creating expense \(error)")
            }
        }
        return nil
    }
    
    func saveWithAttachments(attachments: [Data]) async -> String {
        guard let expense = self.expense else {
            return "No expense defined"
        }
        var expenseId = expense.id
        if expense.id == nil {
            expenseId = self.save()
        }
        guard let id = expenseId else {
            return "Failed to save expense"
        }
        do {
            let objectIds = try await withThrowingTaskGroup(of: StorageMetadata.self, returning: [String].self) { group in
                for data in attachments {
                    group.addTask {
                        let imageUuid = UUID()
                        print(imageUuid)
                        let imageRef = self.storage.reference(withPath: "expenseAttachments/\(id)/\(imageUuid).png")
                        return try await imageRef.putDataAsync(data)
                    }
                }
                return try await group.reduce(into: [String]()) { partialResult, metadata in
                    partialResult.append(metadata.name!)
                }
            }
            self.expense?.attachmentObjectIds.append(contentsOf: objectIds)
            self.expense?.id = id
            let result = self.save()
            if result != nil {
                return "Expense saved successfully"
            } else {
                return "Failed to upload attachments"
            }
        } catch {
            print(error)
            return "Failed to upload attachments"
        }
        
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

