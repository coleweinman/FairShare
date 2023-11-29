//
//  MultiSelectNav.swift
//  FairShare
//
//  Created by Melody Yin on 11/7/23.
//

import SwiftUI

// Navigation to select involved users
struct MultiSelectNav: View {
    
    // View Model to access current user logged in
    @EnvironmentObject var userViewModel: UserViewModel
    
    var options: [Group]
    // @Binding var selections: [BasicUser]
    @Binding var involvedUsers: UserAmountList
    
    var body: some View {
        VStack{
            NavigationView{
                ZStack {
                    expenseBackgroundColor
                    NavigationLink {
                        MemberSelectView(groups: options, involvedUsers: $involvedUsers, currUserId: userViewModel.user!.id!)
                    } label: {
                        Label("Edit Members On Expense", systemImage: "pencil")
                    }
                }
            }.frame(maxHeight: 40)
            Spacer()
        }
    }
}

// Multi selection to add members to expense
struct MemberSelectView: View {
    
    struct GroupListItem: Identifiable, Hashable {
        let group: Group
        let id = UUID()
    }
    
    struct UserListItem: Identifiable, Hashable {
        let user: BasicUser
        let id = UUID()
    }
    var groups: [GroupListItem]
    var userOptions: [UserListItem] = []
    @State var multiSelection = Set<UUID>()
    @State private var selection = 0
    //var currUser: User?
    @Binding var involvedUsers: UserAmountList
    
    @State var editMode = EditMode.active
    @Environment(\.dismiss) private var dismiss
    
    var currUserId: String
    
    init(groups: [Group], involvedUsers: Binding<UserAmountList>, currUserId: String) {
        self._involvedUsers = involvedUsers
        self.groups = []
        self.userOptions = []
        self.currUserId = currUserId
        //currUser = userViewModel.user
        for group in groups {
            self.groups.append(GroupListItem(group: group))
            for user in group.members {
                let currUserItem = UserListItem(user: user)
                // TODO: Check that can unwrap userViewModel, exclude current user
                if (!userOptions.contains(where: {$0.user.id == user.id}) && currUserId != user.id) {
                    self.userOptions.append(currUserItem)
                }
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack (alignment: .center){
                Picker("Choose member add option", selection: $selection) {
                           Text("Add By Group").tag(0)
                           Text("Add Individual Members").tag(1)
                       }.pickerStyle(.segmented)
                if (selection == 0) {
                    // Add by group
                    List (groups, selection: $multiSelection){
                        //Text($0.group.name)
                        TableCellItemView(
                            title: $0.group.name,
                            amount: "",
                            pfps: $0.group.members.map {m in m.profilePictureUrl},
                            backgroundColor: Color(red: 0.671, green: 0.827, blue: 0.996),
                            cornerRadius: 8
                        )
                    }.toolbar {
                        Button("Done") {
                            // Trigger on change for edit mode
                            editMode = EditMode.inactive
                        }.foregroundColor(.blue)
                      }.navigationTitle("Choose a Group")
                } else {
                    // Add individual members
                    List (userOptions, selection: $multiSelection) {
                        Text($0.user.name)
                    }.toolbar {
                        EditButton()
                    }.navigationTitle("Select Members")
                        .environment(\.editMode, $editMode)
                }
                Text("Selection: \(multiSelection.count)")
                Spacer()
            }.onChange(of: editMode) { newVal in
                var members: UserAmountList = UserAmountList(userAmountList: [])
                if (selection == 0) {
                    // By group
                    for item in multiSelection {
                        // Need to search through groups and userOptions using UUID and return list of users
                        // item is a UUID
                        // Groups
                        let result = groups.filter { $0.id == item}
                        if result.count >= 1 {
                            var newMembers = members.basicUsersToUserAmounts(users: result[0].group.members)
                            members.userAmountList.append(contentsOf: newMembers)
                        }
                    }
                } else {
                    // By user
                    for item in multiSelection {
                        // Need to search through groups and userOptions using UUID and return list of users
                        // item is a UUID
                        // Groups
                        let result = userOptions.filter{$0.id == item}
                        if result.count >= 1 {
                            var newMembers = members.basicUsersToUserAmounts(users: [result[0].user])
                            members.userAmountList.append(contentsOf: newMembers)
                        }
                    }
                    // Add back in current logged in user
                    // TODO: At least 1 group MUST exist --> Put in safeguards for this (check that user is in at least 1 group when starting up creation screen)
                    // Assumption, currUser is a member in all groups in "groups"
                    let someGroup = groups[0].group.members
                    var currUser = someGroup.filter{$0.id == currUserId}
                    let currUserAmount = members.basicUsersToUserAmounts(users: [currUser[0]])
                    members.userAmountList.insert(currUserAmount[0], at: 0)
                }
                involvedUsers.userAmountList = members.userAmountList
                dismiss()
            }
        }
    }
    
}
