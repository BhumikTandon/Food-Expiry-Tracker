import SwiftUI
import ParseSwift

@main
struct FoodExpiryTrackerApp: App {
    
    // Register AppDelegate
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

// Move AppDelegate outside of FoodExpiryTrackerApp struct
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        
        // Initialize Parse
        ParseSwift.initialize(
            applicationId: "bq5CDif8eIFSsVtCZLsmBxcedQxebOGms14jdBjC",   // Replace with Back4App App ID
            clientKey: "w78qqDwudtMLoYYZbGnhmq9RkXw0uEUaT8ERgVE6",   // Replace with Back4App Client Key
            serverURL: URL(string: "https://parseapi.back4app.com")!
        )

        print("✅ Parse initialized successfully")
        
        return true
    }
}

