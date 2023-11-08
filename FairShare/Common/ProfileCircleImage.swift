//
//  ProfileCircleImage.swift
//  FairShare
//
//  Created by Melody Yin on 11/7/23.
//

import SwiftUI
import NukeUI

// Profile picture + name
struct ProfileCircleImage: View {
    
    @EnvironmentObject var userViewModel: UserViewModel
    
    @Binding var userId: String
    //@State var user: BasicUser?
    
    let groupMembers: [BasicUser]
    
    var body: some View {
        HStack (alignment: .center){
            let currUser = setUser()
            if let url = currUser.profilePictureUrl {
                LazyImage(url: url) { state in
                    if let image = state.image {
                        image
                            .resizable()
                            .scaledToFill()
                    } else {
                        ProgressView()
                    }
                    
                }.frame(width: 50, height: 50, alignment: .leading).clipShape(Circle()).overlay{ Circle().stroke(.white, lineWidth: 4) }.shadow(radius: 7)
            } else {
                Image(systemName: "person.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            }
            
            // Spacer()
            Text(currUser.name).padding(.leading, 60)
            
        }.padding([.top, .bottom], -10)
            .onTapGesture() {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
    }
    // If select 'set as self', set to current user logged in
    // Otherwise, hard code to testUser
    func setUser() -> BasicUser {
        if (userId == userViewModel.user!.id) {
            return BasicUser(id: userViewModel.user!.id!, name: userViewModel.user!.name, profilePictureUrl: userViewModel.user!.profilePictureUrl)
        } else {
            for member in groupMembers {
                if member.id == userId {
                    return member
                }
            }
            // TODO: Find correct default, this should not happen
            return BasicUser(id: userViewModel.user!.id!, name: userViewModel.user!.name, profilePictureUrl: userViewModel.user!.profilePictureUrl)
        }
    }
}
