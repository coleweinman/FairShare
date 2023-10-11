//
//  LoginView.swift
//  FairShare
//
//  Created by Cole Weinman on 10/5/23.
//

import SwiftUI

struct LoginView: View {
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Hello, World!")
                NavigationLink(destination: {ContentView()}, label: {Text("Hi")})
                Text("Hello, World!")
            }
            
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
