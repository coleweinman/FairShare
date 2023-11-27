//
//  PersonSelection.swift
//  FairShare
//
//  Created by Melody Yin on 11/7/23.
//

import SwiftUI


struct PersonSelection: View {
    
    var userOptions: [UserListItem]
    @State var multiSelection = Set<UUID>()
    
    @State var editMode = EditMode.active
    @Environment(\.dismiss) private var dismiss
    
    @Binding var selectedUsers: [BasicUser]
    
    struct UserListItem: Identifiable, Hashable {
        let user: BasicUser
        let id = UUID()
    }
    init(userOptions: [BasicUser], selectedUsers: Binding<[BasicUser]>) {
        self._selectedUsers = selectedUsers
        self.userOptions = []
        for user in userOptions {
            self.userOptions.append(UserListItem(user: user))
        }
    }
    
    var body: some View {
        NavigationView {
            List (userOptions, selection: $multiSelection) {
                Text($0.user.name)
            }.toolbar {
                EditButton()
            }.navigationTitle("Select Members")
                .environment(\.editMode, $editMode)
            Text("Selection: \(multiSelection.count)")
            Spacer()
        }.onChange(of: editMode) { newVal in
            var members: [BasicUser] = []
            // By user
            for item in multiSelection {
                // Need to search through groups and userOptions using UUID and return list of users
                // item is a UUID
                // Groups
                let result = userOptions.filter{$0.id == item}
                if result.count >= 1 {
                    members.append(result[0].user)
                }
            }
            print(members)
            selectedUsers = members
            dismiss()
        }
    }
}
