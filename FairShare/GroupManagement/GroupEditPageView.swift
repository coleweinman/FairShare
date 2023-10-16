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
    @ObservedObject var viewModel: GroupViewModel = GroupViewModel()
    @Environment(\.dismiss) private var dismiss
    var groupId: String?
    
    init(groupId: String? = nil) {
        self.groupId = groupId
    }
    
    
    var body: some View {
        VStack {
            if let group = viewModel.group {
                List {
                    Section("Details") {
                        TextField(
                            "Name",
                            text: Binding($viewModel.group)!.name
                        )
                    }
                    
                    Section("Members") {
                        ForEach(group.members) { member in
                            Text(member.name)
                        }
                    }
                    
                    Section("Invited Members") {
                        ForEach(group.invitedMembers) { member in
                            Text(member.name)
                        }
                    }
                    
                    Button {
                        
                    } label: {
                        Text("Invite Member")
                    }
                }
            } else {
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
