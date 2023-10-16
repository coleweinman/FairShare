//
//  LoginPageView.swift
//  FairShare
//
//  Created by Cole Weinman on 10/15/23.
//

import SwiftUI
import FirebaseAuth

public struct CustomTextFieldStyle : TextFieldStyle {
    public func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding() // Set the inner Text Field Padding
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.gray.opacity(0.2))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(Color.gray.opacity(0.2), lineWidth: 1)
            )
    }
}

struct LoginPageView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @EnvironmentObject var viewModel: AuthenticationViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    Text("FairShare")
                        .font(.system(size: 44))
                        .padding(.top, 72)
                        .padding(.bottom, 24)
                    
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
                    
                    Button(action: signIn) {
                        Text("Login")
                    }
                    .buttonStyle(.borderedProminent)
                    .cornerRadius(10)
                    
                    Button {
                        
                    } label: {
                        NavigationLink {
                            SignUpPageView()
                        } label: {
                            Text("Sign Up")
                        }
                    }
                    .buttonStyle(.bordered)
                    .cornerRadius(10)
                    
                    
                    
                    
                    if let error = viewModel.error {
                        Text(error)
                    }
                }
            }
            .textFieldStyle(CustomTextFieldStyle())
            .padding(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24))
        }
        
        
    }
    
    func signIn() {
        viewModel.signInWithEmail(email: email, password: password)
    }
}

struct LoginPageView_Previews: PreviewProvider {
    static var previews: some View {
        LoginPageView().environmentObject(AuthenticationViewModel())
    }
}
