//
//  GroupViewModel.swift
//  FairShare
//
//  Created by Cole Weinman on 10/16/23.
//

import Foundation
import FirebaseFirestore

class ShoppingListViewModel: ObservableObject {
    @Published var shoppingList: ShoppingList?
    @Published var items: [IndexedListItem]?
    
    private var db = Firestore.firestore()
    
    func save() -> Bool {
        guard let shoppingList = self.shoppingList else {
            return false
        }
        if let shoppingListId = shoppingList.id {
            do {
                try db.collection("shoppingLists").document(shoppingListId).setData(from: shoppingList)
                return true
            } catch {
                print("Error saving group \(error)")
            }
        } else {
            do {
                try db.collection("shoppingLists").addDocument(from: shoppingList)
                return true
            } catch {
                print("Error creating group \(error)")
            }
        }
        return false
    }
    
    func fetchData(shoppingListId: String) {
        db.collection("shoppingLists").document(shoppingListId)
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                do {
                    self.shoppingList = try document.data(as: ShoppingList.self)
                    var indexedItems: [IndexedListItem] = []
                    for i in 0 ..< self.shoppingList!.items.count {
                        let item = self.shoppingList!.items[i]
                        indexedItems.append(
                            IndexedListItem(index: i, name: item.name, checked: item.checked)
                        )
                    }
                    self.items = indexedItems
                } catch {
                    print("Error fetching document: \(error)")
                }
            }
    }
}
