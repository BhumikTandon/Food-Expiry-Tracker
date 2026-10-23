//
//  MainView.swift
//  Food Expiry Tracker
//
//  Created by Bhumik Tandon on 3/29/25.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Welcome, \(MyUser.current?.username ?? "User")!")
                .font(.title2)
            
            NavigationLink("View My Food Items", destination: FoodItemListView())
            
            Button("Logout") {
                authManager.logout()
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationBarHidden(true)
    }
}
