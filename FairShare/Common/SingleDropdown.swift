//
//  SingleDropdown.swift
//  FairShare
//
//  Created by Melody Yin on 11/7/23.
//

import SwiftUI

// Picker for single selection of members
struct SingleDropdown: View {
    
    // Parameters: Label for dropdown and list of options
    let labelName: String
    var groupMembers: [BasicUser]
    @EnvironmentObject var userViewModel: UserViewModel
    
    // ID of user selected
    @Binding var selectedItem: String
    
    var body: some View {
        //let memberNames = groupMembers.map { $0.name }
        
        VStack (alignment: .center){
            HStack (alignment: .center) {
                VStack (alignment: .leading){
                    Text(labelName)
                    Button("Set as Self") {
                        // ToDo: Change to use actual name of current user
                        selectedItem = userViewModel.user!.id!
                    }.foregroundColor(clickableTextColor).font(.footnote)
                    // Add HStack with profile picture and name
                }.scenePadding(.all)
                    .onTapGesture() {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                Spacer()
                /*Picker("Select", selection: $selectedItem) {
                    ForEach(memberNames, id: \.self) {
                        Text($0)
                    }
                }*/
                Picker("Select", selection: $selectedItem) {
                    ForEach(groupMembers) { member in
                        Text("\(member.name)")
                    }
                }
                //Text("Selected item: \(selectedItem)")
            }.scenePadding(.all)
            .onTapGesture() {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            // Update image on picker selection
            if (selectedItem != "") {
                ProfileCircleImage(userId: $selectedItem, groupMembers: groupMembers)
            }
        }
        .onTapGesture() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}
