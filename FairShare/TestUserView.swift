//
//  TestUserView.swift
//  FairShare
//
//  Created by Cole Weinman on 10/13/23.
//

import SwiftUI

struct TestUserView: View {
    @ObservedObject private var viewModel = UserViewModel()
    
    var body: some View {
        VStack {
            if let user = viewModel.user {
                Text(user.name)
            } else {
                Text("User nil")
            }
        }
        .onAppear() {
            viewModel.fetchData(uid: "5xuwvjBzryoJsQ3VGLIX")
        }
    }
}

struct TestUserView_Previews: PreviewProvider {
    static var previews: some View {
        TestUserView()
    }
}
