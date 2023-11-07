//
//  ItemListPage.swift
//  FairShare
//
//  Created by Andrew Jaso on 11/6/23.
//

// ShoppingListViewDetail.swift

import SwiftUI

struct ItemListPage: View {
    @State private var isEditing = false
    @State private var newItemName = ""
    @State private var isAlertPresented = false
    @StateObject var listViewModel: ShoppingListViewModel = ShoppingListViewModel()

    var listName: String
    @State var items: [ListItem]
    var listId: String
    

    var body: some View {
        VStack {
            if let list = listViewModel.shoppingList {
                List{
                    ForEach(items.indices, id: \.self) { i in
                        HStack {
                            if isEditing {
                                Button(action: {
                                    self.items.remove(at: i)
                                }) {
                                    Image(systemName: "minus.circle")
                                }
                            } else {
                                Image(systemName: items[i].checked ? "checkmark.square" : "square").onTapGesture {
                                    self.items[i].checked.toggle()
                                }
                            }
                            Text(items[i].name)
                        }
                    }.onDelete(perform: deleteItem)
                }
                
                if isEditing {
                    HStack {
                        Button(action: {
                            isAlertPresented.toggle()
                        }) {
                            Image(systemName: "plus.circle")
                            Text("Add Item")
                        }
                    }
                }
            }
        }.onAppear() {
            listViewModel.fetchData(shoppingListId: listId)
            
        }
                .navigationBarItems(trailing: Button(action: {
                    self.isEditing.toggle()
                }) {
                    Text(isEditing ? "Done" : "Edit")
                })
                .navigationTitle(listName)
                .alert("Enter item name", isPresented: $isAlertPresented) {
                    TextField("", text: $newItemName)
                    HStack {
                        Button("Cancel") {
                            isAlertPresented.toggle()
                        }
                        Spacer()
                        Button("Add", action: addItem)
                    }
                }
    }
    
    
    private func deleteItem(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        listViewModel.shoppingList?.items = items
        listViewModel.save()
    }
    
    private func addItem() {
            items.append(ListItem(name: newItemName, checked: false))
            newItemName = ""
            listViewModel.shoppingList?.items = items
            listViewModel.save()
    }

}
