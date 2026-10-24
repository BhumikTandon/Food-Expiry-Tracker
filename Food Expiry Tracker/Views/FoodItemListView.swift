//
//  FoodItemListView.swift
//  Food Expiry Tracker

import SwiftUI

struct FoodItemListView: View {
    @EnvironmentObject private var foodManager: FoodItemManager

    @State private var searchText = ""
    @State private var selectedCategory: FoodCategory? = nil
    @State private var showAddSheet = false

    var filteredItems: [FoodItem] {
        foodManager.foodItems.filter { item in
            let matchesSearch = searchText.isEmpty || (item.name?.localizedCaseInsensitiveContains(searchText) ?? false)
            let matchesCategory = selectedCategory == nil || item.category == selectedCategory?.rawValue
            return matchesSearch && matchesCategory
        }
        .sorted { ($0.expiryDate ?? .distantFuture) < ($1.expiryDate ?? .distantFuture) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category Filter Pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        CategoryChip(title: "All", isSelected: selectedCategory == nil) {
                            selectedCategory = nil
                        }
                        
                        ForEach(FoodCategory.allCases) { category in
                            CategoryChip(
                                title: category.rawValue,
                                icon: category.icon,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color(.systemGroupedBackground))

                // Item List / Empty State
                if filteredItems.isEmpty {
                    ContentUnavailableView(
                        "No Food Items",
                        systemImage: "fork.knife.circle",
                        description: Text(searchText.isEmpty ? "Tap '+' to add your first item." : "No items match '\(searchText)'.")
                    )
                } else {
                    List {
                        ForEach(filteredItems, id: \.objectId) { item in
                            FoodItemCardView(item: item)
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        }
                        .onDelete(perform: deleteItems)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("My Fridge")
            .searchable(text: $searchText, prompt: "Search items...")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddFoodItemView()
            }
            .onAppear {
                foodManager.fetchFoodItems()
            }
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            let item = filteredItems[index]
            foodManager.deleteFoodItem(item)
        }
    }
}

// MARK: - Food Item Card Component
struct FoodItemCardView: View {
    let item: FoodItem

    var badgeColor: Color {
        switch item.statusColorName {
        case "red": return .red
        case "orange": return .orange
        case "gray": return .gray
        default: return .green
        }
    }

    var body: some View {
        HStack(spacing: 16) {
            // Category Icon Badge
            ZStack {
                Circle()
                    .fill(badgeColor.opacity(0.12))
                    .frame(width: 48, height: 48)
                
                Image(systemName: FoodCategory(rawValue: item.category ?? "")?.icon ?? "takeoutbag.and.cup.and.straw.fill")
                    .font(.title3)
                    .foregroundColor(badgeColor)
            }

            // Name & Quantity with Unit Support
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name ?? "Unnamed Item")
                    .font(.headline)
                    .lineLimit(1)
                
                Text("\(String(format: "%.1f", item.quantity ?? 1.0)) \(item.unit ?? "pcs")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Dynamic Expiry Status Badge
            VStack(alignment: .trailing, spacing: 4) {
                Text(item.statusText)
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(badgeColor.opacity(0.18))
                    .foregroundColor(badgeColor)
                    .clipShape(Capsule())

                if let date = item.expiryDate {
                    Text(date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Category Filter Chip Component
struct CategoryChip: View {
    let title: String
    var icon: String? = nil
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
            }
            .font(.subheadline)
            .fontWeight(isSelected ? .semibold : .regular)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color(.tertiarySystemGroupedBackground))
            .foregroundColor(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
