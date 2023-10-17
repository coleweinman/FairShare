//
//  GroupPageView.swift
//  FairShare
//
//  Created by Cole Weinman on 10/15/23.
//

import SwiftUI

struct GroupPageView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @ObservedObject var viewModel: GroupListViewModel = GroupListViewModel()
    @State var acceptAlertOpen = false
    @State var acceptInvitationText = ""
    
    var body: some View {
        VStack {
            Divider()
            if let groups = viewModel.groups,
               let user = userViewModel.user {
                ScrollView {
                    ForEach(groups) { group in
                        HStack {
                            if !group.isInvited(userId: user.id!) {
                                NavigationLink {
                                    GroupEditPageView(groupId: group.id!)
                                } label: {
                                    TableCellItemView(
                                        title: group.name,
                                        date: Date(),
                                        amount: "",
        //                                pfps: group.members.map {m in m.profilePictureUrl},
                                        pfps: [],
                                        backgroundColor: Color(red: 0.671, green: 0.827, blue: 0.996),
                                        cornerRadius: 8
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            } else {
                                TableCellItemView(
                                    title: group.name,
                                    date: Date(),
                                    amount: "",
    //                                pfps: group.members.map {m in m.profilePictureUrl},
                                    pfps: [],
                                    backgroundColor: Color(red: 255/256, green: 240/256, blue: 205/256),
                                    cornerRadius: 8
                                )
                                .onTapGesture {
                                    let result = viewModel.acceptInvitation(groupId: group.id!, userId: user.id!)
                                    acceptAlertOpen = true
                                    acceptInvitationText = result
                                }
                            }
                        }
                    }.padding()
                }
                .alert(
                    Text("Accept Invitation"),
                    isPresented: $acceptAlertOpen,
                    actions: {
                        Button("Ok") {}
                    },
                    message: {
                        Text(acceptInvitationText)
                    }
                )
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Groups")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink {
                    GroupEditPageView()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .onAppear() {
            if let user = userViewModel.user {
                viewModel.fetchData(uid: user.id!)
            }
        }
    }
        
}

struct GroupPageView_Previews: PreviewProvider {
    static var previews: some View {
        GroupPageView()
    }
}
