//
//  FoodItemManager.swift
//  Food Expiry Tracker
//
//  Created by Bhumik Tandon on 3/29/25.
//

import SwiftUI
import ParseSwift

class FoodItemManager: ObservableObject {
    @Published var foodItems: [FoodItem] = []
    @Published var errorMessage: String = ""
    
    // MARK: - Fetch All Food Items (Fetch all items associated with the current user)
    func fetchFoodItems() {
        guard let currentUser = MyUser.current else {
            self.errorMessage = "You must be logged in to view food items."
            return
        }
        
        // Query food items for the current user
        let query = FoodItem.query("user" == currentUser)
        query.find { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let items):
                    self?.foodItems = items
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Add New Food Item
    func addFoodItem(name: String, expiryDate: Date, quantity: Int) {
        guard let currentUser = MyUser.current else {
            self.errorMessage = "You must be logged in to add food items."
            return
        }
        
        var foodItem = FoodItem()
        foodItem.name = name
        foodItem.expiryDate = expiryDate
        foodItem.quantity = quantity
        foodItem.user = currentUser
        
        // Save the new food item
        foodItem.save { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // After saving, fetch the updated list
                    self?.fetchFoodItems()
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Delete Food Item
    func deleteFoodItem(_ foodItem: FoodItem) {
        foodItem.delete { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // After deletion, fetch the updated list
                    self?.fetchFoodItems()
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
