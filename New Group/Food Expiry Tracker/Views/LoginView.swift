//
//  LoginView.swift
//  Food Expiry Tracker
//
//  Created by Bhumik Tandon on 3/29/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var username = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Login").font(.largeTitle)
            
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if !authManager.errorMessage.isEmpty {
                Text(authManager.errorMessage)
                    .foregroundColor(.red)
            }
            
            Button("Login") {
                authManager.login(username: username, password: password)
            }
            .buttonStyle(.borderedProminent)
            
            NavigationLink("Sign Up", destination: SignUpView())
        }
        .padding()
    }
}
