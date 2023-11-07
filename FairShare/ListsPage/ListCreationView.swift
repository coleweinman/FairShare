//
//  ListCreationView.swift
//  FairShare
//
//  Created by Andrew Jaso on 10/24/23.
//

import SwiftUI

struct ListCreationView: View {
    @State private var listName = ""
    @State private var selectedGroup = 0
    @State var showAlert = false
    @EnvironmentObject var viewModel: GroupListViewModel
    @StateObject var listViewModel: ShoppingListViewModel = ShoppingListViewModel()
    @EnvironmentObject var userViewModel: UserViewModel

    let DEFAULT_LIST = ShoppingList(name: "", groupId: nil, users: [], involvedUserIds: [], items: [], createDate: Date(), lastEditDate: Date())

    var listId: String?
    
    init(listId: String? = nil) {
        self.listId = listId
    }
    
    var body: some View {
        NavigationStack {
            if let list = listViewModel.shoppingList {
            VStack {
                    List {
                        HStack {
                            Text("List Name")
                            Spacer(minLength: 140)
                            TextField("Enter Name", text: Binding($listViewModel.shoppingList)!.name)
                        }
                        Picker("Group", selection: Binding($listViewModel.shoppingList)!.groupId) {
                            Text("No Group").tag("")
                            ForEach(viewModel.groups ?? [], id: \.id) { group in
                                Text(group.name)
                            }
                        }
                    }
                    .background(Color(UIColor.systemGray6))
                    
                    ButtonStyle1(buttonText: "Submit", actionFunction: {self.createListOnSubmit()})
                        .alert(isPresented: $showAlert) {
                            Alert(title: Text(listName), message: Text("Create new list"), dismissButton: .default(Text("OK")))
                        }
                        .padding(.bottom, 100)
                }.padding(.top, 10)
                    .background(Color(UIColor.systemGray6)) // Set the background color for the entire view
            } else {
                Text(listViewModel.shoppingList?.name ?? "")
                ProgressView()
            }
        }
                .onAppear() {
                if let id = listId {
                    listViewModel.fetchData(shoppingListId: id)
                } else {
                    listViewModel.shoppingList = DEFAULT_LIST
                    if let user = userViewModel.user {
                            listViewModel.shoppingList!.users.append(BasicUser(id: user.id!, name: user.name, profilePictureUrl: user.profilePictureUrl))
                                    listViewModel.shoppingList!.involvedUserIds.append(user.id!)
                    }
                }
            }
    }


    func createListOnSubmit(){
        if listViewModel.shoppingList?.groupId == "" {
            listViewModel.shoppingList?.groupId = nil
        } else {
            viewModel.groups?.forEach { group in
                if (group.id == listViewModel.shoppingList?.groupId){
                    listViewModel.shoppingList?.involvedUserIds = group.involvedUserIds
                    listViewModel.shoppingList?.users = group.members
                }
            }
        }
        listViewModel.save()
    }
    
}


struct ListCreationView_Previews: PreviewProvider {
    static var previews: some View {
        ListCreationView()
    }
}
