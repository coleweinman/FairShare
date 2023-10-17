//
//  AuthenticationViewModel.swift
//  FairShare
//
//  Created by Cole Weinman on 10/15/23.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

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
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            self.error = error?.localizedDescription
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
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            self.error = error?.localizedDescription
            if let result = authResult {
                let user = User(name: name, email: email, profilePictureUrl: nil, paymentRemindersEnabled: true, paymentRemindersFrequency: "daily", newExpenseNotificationEnabled: true)
                do {
                    try Firestore.firestore().collection("users").document(result.user.uid).setData(from: user)
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
