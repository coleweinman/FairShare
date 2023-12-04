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
    @State var showConfirmationDialogue: Bool = false
    @Environment(\.presentationMode) private var presentationMode
    
    var groupId: String?
    
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
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
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
                                Spacer()
                                Button(action: {
                                    viewModel.group?.involvedUserIds.removeAll(where: {id in member.id == id})
                                    viewModel.group?.members.removeAll(where: {m in member.id == m.id})
                                }, label: {
                                    Label("trash", systemImage: "trash")
                                            .labelStyle(.iconOnly)
                                })
                            }
                            
                        }
                    }
                    
                    if group.invitedMembers.count > 0 {
                        Section("Invited Members") {
                            ForEach(group.invitedMembers) { member in
                                HStack {
                                    Text(member.name)
                                    Spacer()
                                    Button(action: {
                                        viewModel.group?.involvedUserIds.removeAll(where: {id in member.id == id})
                                        viewModel.group?.invitedMembers.removeAll(where: {m in member.id == m.id})
                                    }, label: {
                                        Label("trash", systemImage: "trash")
                                                .labelStyle(.iconOnly)
                                    })
                                }
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
            if viewModel.group?.id != nil {
                ToolbarItem(placement: .primaryAction) {
                   Button {
                        print("PERFORM DELETE")
                       // Open confirmation of delete with ok and cancel
                       showConfirmationDialogue.toggle()
                    } label: {
                        Image(systemName: "trash").foregroundColor(.red)
                    }
                }
            }
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
        .confirmationDialog("Confirm deletion", isPresented: $showConfirmationDialogue) {
            Button("Confirm") { // Call delete
                viewModel.deleteData(groupId: viewModel.group!.id!)
                self.presentationMode.wrappedValue.dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Delete group?")
        }
        .onAppear() {
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
