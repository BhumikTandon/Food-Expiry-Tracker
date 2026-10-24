//
//  MainView.swift
//  Food Expiry Tracker
//
//  Created by Bhumik Tandon on 3/29/25.


import SwiftUI

struct MainView: View {
    @StateObject private var foodManager = FoodItemManager.shared

    var body: some View {
        TabView {
            FoodItemListView()
                .tabItem {
                    Label("My Fridge", systemImage: "refrigerator")
                }

            ExpiryAnalyticsView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.pie.fill")
                }

            // 🍳 Added Recipes Tab Here
            RecipesView()
                .tabItem {
                    Label("Recipes", systemImage: "fork.knife")
                }

            ProfileSettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .environmentObject(foodManager)
        .task {
            await NotificationManager.shared.requestAuthorization()
        }
    }
}
