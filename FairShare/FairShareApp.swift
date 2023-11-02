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
import FirebaseMessaging

class AppDelegate: NSObject, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    let gcmMessageIDKey = "gcm.message_id"
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: { _, _ in }
        )

        application.registerForRemoteNotifications()

        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        let deviceToken:[String: String] = ["token": fcmToken ?? ""]
        print("Device token: ", deviceToken)
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("SETTING TOKEN!")
        Messaging.messaging().apnsToken = deviceToken
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
                    .preferredColorScheme(.light)
            } else {
                LoginPageView()
                    .environmentObject(authViewModel)
                    .preferredColorScheme(.light)
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
