//
//  LoginPageView.swift
//  FairShare
//
//  Created by Cole Weinman on 10/15/23.
//

import SwiftUI
import FirebaseAuth
import GoogleSignInSwift

public struct CustomTextFieldStyle : TextFieldStyle {
    public func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
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
    @State private var forgotPasswordAlert: Bool = false
    @State private var forgotPasswordConfirmationAlert: Bool = false
    @State private var forgotPasswordEmail: String = ""
    @State private var forgotPasswordResponse: String = ""
    @EnvironmentObject var viewModel: AuthenticationViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    Image("FairShareLogo").resizable().scaledToFit().padding(.top, 72)
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
                    
                    Button {
                        forgotPasswordAlert = true
                        forgotPasswordEmail = ""
                        forgotPasswordResponse = ""
                    } label: {
                        Text("Forgot password")
                    }
                    
                    GoogleSignInButton(action: {
                        Task { @MainActor in
                            await viewModel.signInWithGoogle()
                            
                        }
                    })
                    
                    if let error = viewModel.error {
                        Text(error)
                    }
                }
            }
            .textFieldStyle(CustomTextFieldStyle())
            .padding(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24))
            .alert(
                Text("Forgot Password"),
                isPresented: $forgotPasswordAlert,
                actions: {
                    TextField(
                        "Email",
                        text: $forgotPasswordEmail
                    )
                    Button("Send") {
                        Task {
                            let response = await viewModel.sendPasswordResetEmail(email: forgotPasswordEmail)
                            forgotPasswordResponse = response
                            forgotPasswordConfirmationAlert = true
                        }
                    }
                    Button("Cancel", role: .cancel) {}
                },
                message: {
                    Text("Please provide your email associated with your account")
                }
            )
            .alert(
                Text("Forgot Password"),
                isPresented: $forgotPasswordConfirmationAlert,
                actions: {
                    Button("Ok") {}
                },
                message: {
                    Text(forgotPasswordResponse)
                }
            )
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
