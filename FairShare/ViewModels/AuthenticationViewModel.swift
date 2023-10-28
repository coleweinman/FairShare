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
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            self.error = error?.localizedDescription
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
                    let user = User(name: displayName, email: email, profilePictureUrl: fbResult.user.photoURL, paymentRemindersEnabled: true, paymentRemindersFrequency: "daily", newExpenseNotificationEnabled: true)
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
        Auth.auth().createUser(withEmail: email.lowercased(), password: password) { authResult, error in
            self.error = error?.localizedDescription
            if let result = authResult {
                let user = User(name: name, email: email.lowercased(), profilePictureUrl: nil, paymentRemindersEnabled: true, paymentRemindersFrequency: "daily", newExpenseNotificationEnabled: true)
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
