//
//  AddFoodItemView.swift
//  Food Expiry Tracker
//
//  Created by Ishanshika Arora on 10/22/26.
//

import SwiftUI
import ParseSwift

struct AddFoodItemView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var manager = FoodItemManager.shared

    @State private var name: String = ""
    @State private var quantity: Double = 1.0
    @State private var selectedUnit: FoodUnit = .flOz
    @State private var selectedCategory: FoodCategory = .dairy
    @State private var expiryDate: Date = Date().addingTimeInterval(86400 * 7)
    @State private var errorMessage: String?
    @State private var isSaving: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Item Details
                Section("Item Details") {
                    TextField("Item Name (e.g., Whole Milk)", text: $name)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(FoodCategory.allCases) { category in
                            Label(category.rawValue, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                }

                // MARK: - Quantity & Unit Selection
                Section("Quantity & Unit") {
                    HStack {
                        Text("Quantity")
                        Spacer()
                        TextField("Qty", value: $quantity, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 70)
                        
                        Stepper("", value: $quantity, in: 0.1...999, step: 0.5)
                            .labelsHidden()
                    }

                    Picker("Unit", selection: $selectedUnit) {
                        ForEach(FoodUnit.allCases) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // MARK: - Expiry Date & Presets
                Section("Expiry Date") {
                    DatePicker("Expires On", selection: $expiryDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)

                    HStack(spacing: 8) {
                        QuickDateChip(title: "+3 Days", days: 3, targetDate: $expiryDate)
                        QuickDateChip(title: "+1 Week", days: 7, targetDate: $expiryDate)
                        QuickDateChip(title: "+2 Weeks", days: 14, targetDate: $expiryDate)
                    }
                }

                // MARK: - Error Output
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Add Food Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(isSaving ? "Saving..." : "Save") {
                        saveItem()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || isSaving)
                }
            }
        }
    }

    // MARK: - Parse Persistence
    private func saveItem() {
        guard let currentUser = MyUser.current else {
            errorMessage = "User session expired. Please log in again."
            return
        }

        isSaving = true
        errorMessage = nil

        do {
            var item = FoodItem()
            item.name = name.trimmingCharacters(in: .whitespaces)
            item.quantity = quantity
            item.unit = selectedUnit.rawValue
            item.category = selectedCategory.rawValue
            item.expiryDate = expiryDate
            item.user = try currentUser.toPointer()
            
            // Set ACL permissions using ParseSwift syntax
            var acl = ParseACL()
            if let userId = currentUser.objectId {
                acl.setReadAccess(objectId: userId, value: true)
                acl.setWriteAccess(objectId: userId, value: true)
            }
            item.ACL = acl

            item.save { result in
                DispatchQueue.main.async {
                    isSaving = false
                    switch result {
                    case .success(let savedItem):
                        print("✅ Item saved successfully to Parse: \(savedItem)")
                        manager.fetchFoodItems()
                        dismiss()
                    case .failure(let error):
                        print("❌ Save Failed: \(error.localizedDescription)")
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
        } catch {
            isSaving = false
            print("❌ User Pointer Error: \(error.localizedDescription)")
            self.errorMessage = "Failed to link item to current user."
        }
    }
}

// MARK: - Quick Date Preset Button
struct QuickDateChip: View {
    let title: String
    let days: Int
    @Binding var targetDate: Date

    var body: some View {
        Button(action: {
            targetDate = Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
        }) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.12))
                .foregroundColor(.blue)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AddFoodItemView()
}
