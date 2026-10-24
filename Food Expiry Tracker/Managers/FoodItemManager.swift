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

    /// Clears everything tied to the signed-in user. Called on logout.
    func reset() {
        foodItems = []
        errorMessage = nil
    }

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
                        self?.errorMessage = nil
                        self?.foodItems = items
                        NotificationManager.shared.sync(items)
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                    }
                }
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func deleteFoodItem(_ item: FoodItem) {
        item.delete { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.foodItems.removeAll { $0.objectId == item.objectId }
                    NotificationManager.shared.sync(self?.foodItems ?? [])
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    // MARK: - Recipe ingredients

    /// Ingredient names to send to the recipe search: expired items are left out,
    /// the soonest-to-expire items come first, duplicates are removed, and the list
    /// is capped so the closest-to-expiring items are what drive the suggestions.
    static func recipeIngredients(
        from items: [FoodItem],
        limit: Int = 10,
        asOf now: Date = Date(),
        calendar: Calendar = .current
    ) -> [String] {
        let usable = items
            .filter { item in
                guard let name = item.name?.trimmingCharacters(in: .whitespaces), !name.isEmpty else { return false }
                return item.status(asOf: now, calendar: calendar) != .expired
            }
            .sorted { ($0.expiryDate ?? .distantFuture) < ($1.expiryDate ?? .distantFuture) }

        var seen = Set<String>()
        var names: [String] = []
        for item in usable {
            guard let name = item.name?.trimmingCharacters(in: .whitespaces) else { continue }
            if seen.insert(name.lowercased()).inserted {
                names.append(name)
            }
            if names.count == limit { break }
        }
        return names
    }
}
