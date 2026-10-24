//
//  ProfileSettingsView.swift
//  Food Expiry Tracker
//
//  Created by Ishanshika Arora on 10/22/26.
//
import SwiftUI
import ParseSwift

struct ProfileSettingsView: View {
    @EnvironmentObject private var authManager: AuthManager

    var currentUser: MyUser? {
        MyUser.current
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Account Details") {
                    HStack {
                        Text("Username")
                        Spacer()
                        Text(currentUser?.username ?? "N/A")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Email")
                        Spacer()
                        Text(currentUser?.email ?? "N/A")
                            .foregroundColor(.secondary)
                    }
                }

                Section {
                    Button(role: .destructive) {
                        authManager.logout()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Log Out")
                                .fontWeight(.medium)
                            Spacer()
                        }
                    }

                    if !authManager.errorMessage.isEmpty {
                        Text(authManager.errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
