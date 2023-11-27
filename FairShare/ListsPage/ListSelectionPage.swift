//
//  ListSelectionPage.swift
//  FairShare
//
//  Created by Cole Weinman on 11/25/23.
//

import SwiftUI

struct ListSelectionPage: View {
    @StateObject var viewModel: ShoppingListListViewModel = ShoppingListListViewModel()
    @EnvironmentObject var userViewModel: UserViewModel
    
    var onSelect: ((ShoppingList) -> Void)
    
    var body: some View {
        ScrollView {
            if let lists = viewModel.shoppingLists {
                Text("Select List").padding()
                VStack {
                    ForEach(lists) { list in
                        TableCellItemView(
                            title: list.name,
                            amount: "",
                            pfps: list.users.map { m in m.profilePictureUrl },
                            backgroundColor: Color(red: 0.671, green: 0.827, blue: 0.996),
                            cornerRadius: 8
                        )
                        .onTapGesture {
                            onSelect(list)
                        }
                    }
                }.padding()
            } else {
                ProgressView()
            }
            
        }
        .onAppear {
            if let user = userViewModel.user {
                viewModel.fetchData(uid: user.id!)
            }
        }
        
    }
}

//#Preview {
//    ListSelectionPage()
//}
