//
//  ExpiryAnalyticsView.swift
//  Food Expiry Tracker
//
//  Created by Ishanshika Arora on 10/22/26.
//
//  ExpiryAnalyticsView.swift
//  Food Expiry Tracker

// ExpiryAnalyticsView.swift
import SwiftUI

struct ExpiryAnalyticsView: View {
    @EnvironmentObject private var manager: FoodItemManager

    private func items(where matches: (ExpiryStatus) -> Bool) -> [FoodItem] {
        manager.foodItems
            .filter { matches($0.status()) }
            .sorted { ($0.expiryDate ?? .distantFuture) < ($1.expiryDate ?? .distantFuture) }
    }

    var expiredCount: Int { items { $0 == .expired }.count }
    var expiringSoonCount: Int { items { $0 == .expiringSoon }.count }
    var freshCount: Int { items { $0 == .fresh }.count }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Stat Summary Cards
                    HStack(spacing: 12) {
                        StatCard(title: "Expired", count: expiredCount, color: .red, icon: "exclamationmark.triangle.fill")
                        StatCard(title: "Expiring Soon", count: expiringSoonCount, color: .orange, icon: "clock.badge.exclamationmark.fill")
                        StatCard(title: "Fresh", count: freshCount, color: .green, icon: "checkmark.circle.fill")
                    }
                    .padding(.horizontal)

                    // Urgent Section (0 - 3 Days)
                    let urgentItems = items { $0 == .expired || $0 == .expiringSoon }
                    if !urgentItems.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Urgent (Expiring Soon)")
                                .font(.headline)
                                .foregroundColor(.orange)

                            ForEach(urgentItems, id: \.objectId) { item in
                                FoodItemCardView(item: item)
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Fresh Section (>3 Days)
                    let freshItems = items { $0 == .fresh }
                    if !freshItems.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Fresh Items")
                                .font(.headline)
                                .foregroundColor(.green)

                            ForEach(freshItems, id: \.objectId) { item in
                                FoodItemCardView(item: item)
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Items saved without an expiry date
                    let undatedItems = items { $0 == .noDate }
                    if !undatedItems.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("No Expiry Date")
                                .font(.headline)
                                .foregroundColor(.gray)

                            ForEach(undatedItems, id: \.objectId) { item in
                                FoodItemCardView(item: item)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Analytics")
            .onAppear {
                manager.fetchFoodItems()
            }
        }
    }
}

// MARK: - Stat Card Component
struct StatCard: View {
    let title: String
    let count: Int
    let color: Color
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text("\(count)")
                .font(.title)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}

#Preview {
    ExpiryAnalyticsView()
}
