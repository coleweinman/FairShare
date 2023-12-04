//
//  SignUpPageView.swift
//  FairShare
//
//  Created by Cole Weinman on 10/15/23.
//

import SwiftUI

struct SignUpPageView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @State private var errorAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    Image("FairShareLogo").resizable().scaledToFit().padding(.top, 72)
                        .padding(.bottom, 24)
                    Text("Name")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    TextField(
                        "Name",
                        text: $name
                    )
                    .padding(.top, -8)
                    .padding(.bottom, 16)
                    
                    Text("Email")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    TextField(
                        "Email",
                        text: $email
                    )
                    .padding(.top, -8)
                    .padding(.bottom, 16)
                    
                    Text("Password")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    SecureField(
                        "Password",
                        text: $password
                    )
                    .padding(.top, -8)
                    .padding(.bottom, 16)
                    
                    Button(action: signUp) {
                        Text("Sign Up")
                    }
                    .buttonStyle(.borderedProminent)
                    .cornerRadius(10)
                    
                    if let error = viewModel.error {
                        Text(error)
                    }
                }
            }
            .alert(
                Text("Sign Up Error"),
                isPresented: $errorAlert,
                actions: {
                    Button("Ok") {}
                },
                message: {
                    Text(viewModel.error ?? "")
                }
            )
            .onChange(of: errorAlert) { value in
                if !value {
                    viewModel.error = nil
                }
            }
            .onChange(of: viewModel.error) { value in
                if value != nil {
                    errorAlert = true
                }
            }
            .textFieldStyle(CustomTextFieldStyle())
            .padding(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24))
        }
    }
    
    func signUp() {
        viewModel.signUp(name: name, email: email, password: password)
    }
}

struct SignUpPageView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpPageView().environmentObject(AuthenticationViewModel())
    }
}
