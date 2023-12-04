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
    @Environment(\.presentationMode) private var presentationMode

    @StateObject var listViewModel: ShoppingListViewModel = ShoppingListViewModel()
    @StateObject var shoppinglistViewModel: ShoppingListListViewModel = ShoppingListListViewModel()


    var listName: String
    @State var showConfirmationDialogue = false
    var listId: String
    

    var body: some View {
        VStack {
            if let list = listViewModel.shoppingList,
               let items = listViewModel.items
            {
                List {
                    ForEach(listViewModel.items!) { item in
                            HStack {
                                if isEditing {
                                    Button(action: {
                                        var newItems = listViewModel.shoppingList!.items
                                        newItems.remove(at: item.index)
                                        listViewModel.shoppingList?.items = newItems
                                        listViewModel.save()
                                    }) {
                                        Image(systemName: "minus.circle")
                                    }
                                } else {
                                    Image(systemName: item.checked ? "checkmark.square" : "square").onTapGesture {
                                        listViewModel.shoppingList!.items[item.index].checked.toggle()
                                        listViewModel.save()
                                    }
                                }
                                Text(item.name)
                            }
                        }
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
            .navigationBarItems(trailing: 
                                    HStack {
                Button(action: {
                    self.isEditing.toggle()
                }) {
                    Text(isEditing ? "Done" : "Edit")
                }
                Button(action: {
                    showConfirmationDialogue.toggle()
                }) {
                    Image(systemName: "trash").foregroundColor(.red)
                }
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
                }.confirmationDialog("Confirm deletion", isPresented: $showConfirmationDialogue){
                    Button("Confirm") {
                                        deleteList()
                                        self.presentationMode.wrappedValue.dismiss()
                                    }
                                    Button("Cancel", role: .cancel) { }
                                } message: {
                                    Text("Delete List?")
                        }
                }
    
    
    private func deleteList() {
        let idString = listViewModel.shoppingList?.id ?? ""
        shoppinglistViewModel.remove(shoppingListId: idString)
        
    }
    
    private func addItem() {
            listViewModel.shoppingList?.items.append(ListItem(name: newItemName, checked: false))
            newItemName = ""
            listViewModel.save()
    }

}
