import SwiftUI
import ParseSwift
import UserNotifications

@main
struct FoodExpiryTrackerApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var authManager = AuthManager()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                // If the user is logged in, show MainView; otherwise, show LoginView
                if authManager.isAuthenticated {
                    MainView()
                } else {
                    LoginView()
                }
            }
            .environmentObject(authManager)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {

        // Keys live in Secrets.swift, which is gitignored. See Secrets.swift.example.
        ParseSwift.initialize(
            applicationId: Secrets.parseApplicationId,
            clientKey: Secrets.parseClientKey,
            serverURL: URL(string: "https://parseapi.back4app.com")!
        )

        UNUserNotificationCenter.current().delegate = self
        return true
    }

    // Show expiry reminders as banners even while the app is open.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}
