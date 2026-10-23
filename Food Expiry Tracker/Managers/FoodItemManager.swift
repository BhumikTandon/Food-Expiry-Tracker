//
//  FoodItemManager.swift
//  Food Expiry Tracker
//
//  Created by Bhumik Tandon on 3/29/25.
//
import Foundation
import ParseSwift
import Combine

class FoodItemManager: ObservableObject {
    static let shared = FoodItemManager()
    
    @Published var foodItems: [FoodItem] = []
    @Published var errorMessage: String?

    func fetchFoodItems() {
        guard let currentUser = MyUser.current else {
            self.errorMessage = "User not logged in."
            return
        }

        do {
            // Convert current user to a Parse Pointer to match the database schema
            let userPointer = try currentUser.toPointer()
            let query = FoodItem.query("user" == userPointer)
            
            query.find { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let items):
                        print("✅ Successfully fetched \(items.count) food items.")
                        self?.foodItems = items
                    case .failure(let error):
                        print("❌ Fetch Error: \(error.localizedDescription)")
                        self?.errorMessage = error.localizedDescription
                    }
                }
            }
        } catch {
            print("❌ Pointer conversion error: \(error.localizedDescription)")
            self.errorMessage = error.localizedDescription
        }
    }

    func deleteFoodItem(_ item: FoodItem) {
        item.delete { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("✅ Item deleted successfully.")
                    self?.foodItems.removeAll { $0.objectId == item.objectId }
                case .failure(let error):
                    print("❌ Delete Error: \(error.localizedDescription)")
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
