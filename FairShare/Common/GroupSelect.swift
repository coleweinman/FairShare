//
//  GroupSelect.swift
//  FairShare
//
//  Created by Melody Yin on 11/7/23.
//

import SwiftUI

// Picker to select group for expense
struct GroupSelect: View {
    @ObservedObject var groupViewModel: GroupViewModel = GroupViewModel()
    //@EnvironmentObject var groupViewModel: GroupViewModel
    
    var groups: [Group]
    @Binding var selectedItem: String
    @State var groupId: String?
    @Binding var members: [BasicUser]
    
    var body: some View {
        let groupNames = groups.map { $0.name }
        HStack(alignment: .center) {
            Text("Group").padding(.leading, 20)
            Spacer()
            Picker("Select", selection: $selectedItem) {
                ForEach(groupNames, id: \.self) {
                    Text($0)
                }
            }.onReceive([self.selectedItem].publisher.first()) { value in
                for group in groups {
                    if (group.name == value) {
                        groupViewModel.fetchData(groupId: selectedItem)
                        groupId = group.id
                        members = group.members
                    }
                }
                
            }
        }.scenePadding(.all)
    }
}

