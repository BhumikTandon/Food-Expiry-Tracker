//
//  ProfileSettingsView.swift
//  Food Expiry Tracker
//
//  Created by Ishanshika Arora on 10/22/26.
//
import SwiftUI
import ParseSwift

struct ProfileSettingsView: View {
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
                    Button(role: .destructive, action: logoutUser) {
                        HStack {
                            Spacer()
                            Text("Log Out")
                                .fontWeight(.medium)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }

    private func logoutUser() {
        MyUser.logout { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("User logged out successfully")
                case .failure(let error):
                    print("Logout error: \(error.localizedDescription)")
                }
            }
        }
    }
}
