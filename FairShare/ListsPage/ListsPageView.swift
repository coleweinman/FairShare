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
    @StateObject var listsViewModel: ShoppingListListViewModel = ShoppingListListViewModel()
    var cardBackgroundColor: Color = Color(red: 1, green: 1, blue: 1, opacity: 1)
    var cardOuterCornerRadius: CGFloat = 24
    var cardPadding: CGFloat = 16
    
    var body: some View {
        VStack {
            if let lists = listsViewModel.shoppingLists {
                VStack {
                    if lists.count > 0 {
                        ForEach(lists) { list in
                           ListCell(list: list, userId: userViewModel.user!.id!)
                        }
                        .onDelete(perform: deleteList)
                    } else {
                        Spacer()
                        Image("duck3")
                        Text("You don't have any lists yet!")
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(cardPadding)
                .background(cardBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: cardOuterCornerRadius))
            } else {
                ProgressView()
            }
            Spacer()
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

struct ListCell: View {
    let list: ShoppingList
    let userId: String
    @StateObject var listsViewModel: ShoppingListListViewModel = ShoppingListListViewModel()


       var body: some View {

           return NavigationLink {
               ItemListPage(listName: list.name, listId: list.id!)
           } label: {
               TableCellItemView(
                   title: list.name,
                   date: list.createDate,
                   amount: "",
                   pfps: list.users.map {m in m.profilePictureUrl},
                   backgroundColor: Color(red: 0.788, green: 0.894, blue: 0.871, opacity: 0.75),
                   cornerRadius: 8
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
