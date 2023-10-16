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
    
    var body: some View {
        VStack {
            Divider()
            Text(viewModel.groups?.count.formatted() ?? "nothin")
            if let groups = viewModel.groups {
                ScrollView {
                    ForEach(groups) { group in
                        NavigationLink {
                            GroupEditPageView(groupId: group.id)
                        } label: {
                            Text(group.name)
                        }
                    }
                }
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
