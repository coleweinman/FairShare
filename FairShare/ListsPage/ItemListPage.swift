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
    //@State var items: [ListItem]
    var listId: String
    

    var body: some View {
        VStack {
            if let list = listViewModel.shoppingList,
               let items = listViewModel.items
            {
                List {
                    //ForEach(Binding($listViewModel.shoppingList)!.items.indices, id: \.self) { i in
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
       // items.remove(atOffsets: offsets)
//        var newItems = listViewModel.shoppingList!.items
//        newItems.remove(at: offsets)
//        listViewModel.shoppingList?.items = newItems
//        listViewModel.save()
    }
    
    private func addItem() {
            listViewModel.shoppingList?.items.append(ListItem(name: newItemName, checked: false))
            newItemName = ""
            //listViewModel.shoppingList?.items = items
            listViewModel.save()
    }

}
