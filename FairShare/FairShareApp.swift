//
//  FairShareApp.swift
//  FairShare
//
//  Created by Cole Weinman on 10/5/23.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()

        return true
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }
}

@main
struct FairShareApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authViewModel = AuthenticationViewModel()
    @Environment(\.scenePhase) private var scenePhase
    @State private var authHandler: AuthStateDidChangeListenerHandle?
    
    var body: some Scene {
        WindowGroup {
            if authViewModel.user != nil {
                MainTabView()
                    .environmentObject(authViewModel)
            } else {
                LoginPageView()
                    .environmentObject(authViewModel)
            }
        }.onChange(of: scenePhase) { phase in
            print(phase)
            if phase == .active {
                print("ACTIVE")
                authViewModel.startAuthListener()
            }
        }
    }
}
