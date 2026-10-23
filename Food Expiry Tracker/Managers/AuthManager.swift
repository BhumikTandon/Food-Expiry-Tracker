//
//  AuthManager.swift
//  Food Expiry Tracker
//
//  Created by Bhumik Tandon on 3/29/25.
//

import SwiftUI
import ParseSwift

class AuthManager: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String = ""
    
    // Check if there's a current user at app launch
    init() {
        if MyUser.current != nil {
            // Already logged in from a previous session
            isAuthenticated = true
        }
    }
    
    // MARK: - Sign Up
    func signUp(username: String, email: String, password: String) {
        var newUser = MyUser()
        newUser.username = username
        newUser.email = email
        newUser.password = password
        
        newUser.signup { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.isAuthenticated = true
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Login
    func login(username: String, password: String) {
        MyUser.login(username: username, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.isAuthenticated = true
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Logout
    func logout() {
        MyUser.logout { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.isAuthenticated = false
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

