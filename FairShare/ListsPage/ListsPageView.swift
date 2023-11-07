//
//  ListsPageView.swift
//  FairShare
//
//  Created by Cole Weinman on 10/10/23.
//

import SwiftUI

struct ListsPageView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var viewModel: ShoppingListViewModel
    @StateObject  var listsViewModel: ShoppingListListViewModel = ShoppingListListViewModel()

    
    var body: some View {
        VStack {
        if let lists = listsViewModel.shoppingLists {
            NavigationStack {
                List {
                    ForEach(lists) { list in
                        NavigationLink(destination: ItemListPage(listName: list.name, items:list.items, listId: list.id!)){
                            Text(list.name)
                        }
                    }
                    .onDelete(perform: deleteList)
                }
            }
        } else {
            ProgressView()
        }
    }
    .onAppear() {
        if let user = userViewModel.user {
            listsViewModel.fetchData(uid: user.id!)
        }
    }
    }
    func deleteList(at offsets: IndexSet) {
           if let index = offsets.first {
               let listToDelete = listsViewModel.shoppingLists![index]
               listsViewModel.remove(shoppingListId: listToDelete.id!)
           }
       }
}

struct ListsPageView_Previews: PreviewProvider {
    static var previews: some View {
        ListsPageView()
    }
}
