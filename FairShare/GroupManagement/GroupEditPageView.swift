//
//  GroupEditPageView.swift
//  FairShare
//
//  Created by Cole Weinman on 10/16/23.
//

import SwiftUI

let DEFAULT_GROUP = Group(name: "", members: [], invitedMembers: [], involvedUserIds: [])

struct GroupEditPageView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @StateObject var viewModel: GroupViewModel = GroupViewModel()
    @Environment(\.dismiss) private var dismiss
    @State var openAlert = false
    @State var openInviteResponse = false
    @State var inviteUserEmail: String = ""
    @State var inviteUserResponse: String = ""
    
    var groupId: String?
    
    init(groupId: String? = nil) {
        print("INIT")
        self.groupId = groupId
    }
    
    var body: some View {
        VStack {
            Divider()
            if let group = viewModel.group {
                List {
                    Section("Details") {
                        HStack {
                            Text("Name")
                                .padding(.trailing, 10)
                            TextField(
                                "Group Name",
                                text: Binding($viewModel.group)!.name
                            )
                        }
                        
                    }
                    
                    Section("Members") {
                        ForEach(group.members) { member in
                            HStack {
                                if let profileUrl = member.profilePictureUrl {
                                    AsyncImage(url: profileUrl) { image in
                                        image.resizable()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 32, height: 32)
                                    .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.fill")
                                        .resizable()
                                        .frame(width: 32, height: 32)
                                        .clipShape(Circle())
                                }
                                Text(member.name)
                            }
                            
                        }
                    }
                    
                    if group.invitedMembers.count > 0 {
                        Section("Invited Members") {
                            ForEach(group.invitedMembers) { member in
                                Text(member.name)
                            }
                        }
                    }
                    
                    HStack {
                        Spacer()
                        Button {
                            openAlert = true
                        } label: {
                            Text("Invite Member")
                        }
                        Spacer()
                    }
                }
            } else {
                Text(viewModel.group?.name ?? "no group")
                ProgressView()
            }
        }
        .navigationTitle("Group Editor")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    let saveResult = viewModel.save()
                    if saveResult {
                        dismiss()
                    }
                } label: {
                    Text("Done")
                }
            }
        }
        .alert(
            Text("Invite Member"),
            isPresented: $openAlert,
            actions: {
                TextField(
                    "Email",
                    text: $inviteUserEmail
                )
                Button("Invite") {
                    Task {
                        let response = await viewModel.inviteUserByEmail(email: inviteUserEmail)
                        inviteUserResponse = response
                        openInviteResponse = true
                    }
                }
                Button("Cancel", role: .cancel) {}
            },
            message: {
                Text("Please type email of user to invite")
            }
        )
        .alert(
            Text("Invite Member"),
            isPresented: $openInviteResponse,
            actions: {
                Button("Ok") {}
            },
            message: {
                Text(inviteUserResponse)
            }
        )
        .onAppear() {
            print("on appaer")
            if let id = groupId {
                viewModel.fetchData(groupId: id)
            } else {
                viewModel.group = DEFAULT_GROUP
                if let user = userViewModel.user
                {
                    viewModel.group!.members.append(BasicUser(id: user.id!, name: user.name, profilePictureUrl: user.profilePictureUrl))
                    viewModel.group!.involvedUserIds.append(user.id!)
                }
                
            }
        }
    }
}

struct GroupEditPageView_Previews: PreviewProvider {
    static var previews: some View {
        GroupEditPageView()
            .environmentObject(UserViewModel())
    }
}
