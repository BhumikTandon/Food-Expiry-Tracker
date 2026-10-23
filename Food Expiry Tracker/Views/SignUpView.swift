//
//  SignUpView.swift
//  Food Expiry Tracker
//
//  Created by Ishanshika Arora on 10/22/26.
//

import SwiftUI
import ParseSwift

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Account Details")) {
                    TextField("Username", text: $username)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                    
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                    
                    SecureField("Password", text: $password)
                }

                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }

                Button(action: signUpUser) {
                    Text("Create Account")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle("Sign Up")
        }
    }

    private func signUpUser() {
        var newUser = MyUser()
        newUser.username = username
        newUser.email = email
        newUser.password = password

        newUser.signup { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    print("User signed up successfully: \(user)")
                    dismiss()
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    SignUpView()
}
