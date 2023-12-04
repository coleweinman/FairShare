//
//  AuthenticationViewModel.swift
//  FairShare
//
//  Created by Cole Weinman on 10/15/23.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import GoogleSignIn

class AuthenticationViewModel: ObservableObject {
    @Published var user: FirebaseAuth.User?
    @Published var error: String?
    private var authHandler: AuthStateDidChangeListenerHandle?
    
    func startAuthListener() {
        authHandler = Auth.auth().addStateDidChangeListener { auth, user in
            self.user = user
            print(user?.email ?? "No user")
        }
    }
    
    func endAuthListener() {
        Auth.auth().removeStateDidChangeListener(authHandler!)
    }
    
    func signInWithEmail(email: String, password: String) {
        if email == "" {
            self.error = "Email not provided"
            return
        }
        if password == "" {
            self.error = "Password not provided"
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error as NSError? {
                guard let errorCode = AuthErrorCode.Code(rawValue: error.code) else {
                    self.error = "Unknown error. Please try again later."
                    return
                }
                switch errorCode {
                case .invalidEmail:
                    self.error = "Invalid email"
                case .weakPassword:
                    self.error = "Password is too weak"
                case .wrongPassword:
                    self.error = "Invalid password"
                case .userDisabled:
                    self.error = "Account is disabled"
                default:
                    self.error = "Invalid credentials"
                }
            } else {
                self.error = nil
            }
        }
    }
    
    func signInWithGoogle() async {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            self.error = "Error signing in with Google"
            return
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            self.error = "Error signing in with Google"
            return
        }
        guard let rootViewController = await windowScene.windows.first?.rootViewController else {
            self.error = "Error signing in with Google"
            return
        }
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            if let idToken = result.user.idToken?.tokenString {
                let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                               accessToken: result.user.accessToken.tokenString)
                let fbResult = try await Auth.auth().signIn(with: credential)
                if let displayName = fbResult.user.displayName,
                   let email = fbResult.user.email
                {
                    let user = User(name: displayName, email: email, profilePictureUrl: fbResult.user.photoURL, paymentRemindersEnabled: true, paymentRemindersFrequency: "Daily", newExpenseNotificationEnabled: true)
                    do {
                        let userDoc = try await Firestore.firestore().collection("users").document(fbResult.user.uid).getDocument()
                        if !userDoc.exists {
                            try Firestore.firestore().collection("users").document(fbResult.user.uid).setData(from: user)
                            try Firestore.firestore().collection("users").document(fbResult.user.uid).collection("secure").document("balances").setData(from: BalanceData(netBalances: [:]))
                        }
                    } catch {
                        print(error)
                    }
                }
            }
        } catch {
            self.error = error.localizedDescription
        }
        
    }
    
    func sendPasswordResetEmail(email: String) async -> String {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            return "Password reset email sent successfully"
        } catch {
            return "Unable to send password reset email"
        }
        
    }
    
    func signUp(name:String, email: String, password: String) {
        if name == "" {
            self.error = "Name not provided"
            return
        }
        if email == "" {
            self.error = "Email not provided"
            return
        }
        if password == "" {
            self.error = "Password not provided"
            return
        }
        Auth.auth().createUser(withEmail: email.lowercased(), password: password) { authResult, error in
            if let error = error as NSError? {
                guard let errorCode = AuthErrorCode.Code(rawValue: error.code) else {
                    self.error = "Unknown error. Please try again later."
                    print(error.code)
                    return
                }
                switch errorCode {
                case .invalidEmail:
                    self.error = "Invalid email"
                case .emailAlreadyInUse:
                    self.error = "Email already in use"
                case .weakPassword:
                    self.error = "Password is too weak"
                case .userDisabled:
                    self.error = "Account is disabled"
                default:
                    print(errorCode.rawValue)
                    self.error = "Unknown error. Please try again later."
                }
            } else {
                self.error = nil
            }
            
            if let result = authResult {
                let user = User(name: name, email: email.lowercased(), profilePictureUrl: nil, paymentRemindersEnabled: true, paymentRemindersFrequency: "Daily", newExpenseNotificationEnabled: true)
                do {
                    try Firestore.firestore().collection("users").document(result.user.uid).setData(from: user)
                    try Firestore.firestore().collection("users").document(result.user.uid).collection("secure").document("balances").setData(from: BalanceData(netBalances: [:]))
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func signOut() -> Bool {
        do {
            try Auth.auth().signOut()
            return true
        } catch {
            print(error)
            return false
        }
    }
}
