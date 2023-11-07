//
//  ExpenseListViewModel.swift
//  FairShare
//
//  Created by Cole Weinman on 10/13/23.
//

import Foundation
import FirebaseFirestore

class ShoppingListListViewModel: ObservableObject {
    @Published var shoppingLists: [ShoppingList]?
    
    private var db = Firestore.firestore()
    
    func add(shoppingList: ShoppingList) -> String? {
        do {
            let docRef = try db.collection("expenses").addDocument(from: shoppingList)
            return docRef.documentID
        } catch {
            return nil
        }
    }
    
    func update(shoppingList: ShoppingList) -> Bool {
        do {
            guard let listId = shoppingList.id else {
                return false
            }
            try db.collection("shoppingLists").document(listId).setData(from: shoppingList)
            return true
        } catch {
            return false
        }
    }
    
    func remove(shoppingListId: String) {
        db.collection("shoppingLists").document(shoppingListId).delete()
    }
    
    func fetchData(uid: String) {
        db.collection("shoppingLists").whereField("involvedUserIds", arrayContains: uid).order(by: "lastEditDate", descending: true)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                do {
                    let shoppingLists = try documents.map { doc in
                        return try doc.data(as: ShoppingList.self)
                    }
                    print(shoppingLists)
                    self.shoppingLists = shoppingLists
                } catch {
                    print(error)
                    self.shoppingLists = []
                }
            }
    }
}
