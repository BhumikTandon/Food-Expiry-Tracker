//
//  RecipesView.swift
//  Food Expiry Tracker
//
//  Created by Ishanshika Arora on 10/23/26.
//


import SwiftUI

struct RecipesView: View {
    @EnvironmentObject private var foodManager: FoodItemManager
    @State private var recipes: [SpoonacularRecipe] = []
    @State private var selectedRecipe: SpoonacularRecipe? = nil
    @State private var isLoading = false
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Finding recipes with your ingredients...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                } else if let errorMessage = errorMessage {
                    ContentUnavailableView(
                        "Search Failed",
                        systemImage: "exclamationmark.triangle",
                        description: Text(errorMessage)
                    )
                } else if recipes.isEmpty {
                    ContentUnavailableView(
                        "No Recipes Found",
                        systemImage: "fork.knife.circle",
                        description: Text("Add food items to your fridge to see recipe recommendations.")
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(recipes) { recipe in
                                SpoonacularRecipeCard(recipe: recipe)
                                    .onTapGesture {
                                        selectedRecipe = recipe
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Recipes")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Task { await fetchRecipes() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(isLoading)
                }
            }
            .sheet(item: $selectedRecipe) { recipe in
                SpoonacularDetailSheet(recipe: recipe)
            }
            .onAppear {
                if recipes.isEmpty {
                    Task { await fetchRecipes() }
                }
            }
        }
    }

    private func fetchRecipes() async {
        let ingredientNames = foodManager.foodItems.compactMap { $0.name }.filter { !$0.isEmpty }
        guard !ingredientNames.isEmpty else {
            self.recipes = []
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let fetched = try await SpoonacularService.shared.searchByIngredients(ingredientNames)
            DispatchQueue.main.async {
                self.recipes = fetched
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Could not connect to Spoonacular. Verify your API key."
                self.isLoading = false
            }
        }
    }
}

// MARK: - Recipe Card Component
struct SpoonacularRecipeCard: View {
    let recipe: SpoonacularRecipe

    var body: some View {
        HStack(spacing: 16) {
            AsyncImage(url: URL(string: recipe.image ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                default:
                    Color.gray.opacity(0.15)
                        .overlay {
                            Image(systemName: "fork.knife")
                                .foregroundColor(.gray)
                        }
                }
            }
            .frame(width: 80, height: 80)
            .cornerRadius(12)

            VStack(alignment: .leading, spacing: 6) {
                Text(recipe.title)
                    .font(.headline)
                    .lineLimit(2)

                HStack(spacing: 8) {
                    Text("\(recipe.usedIngredientCount) in fridge")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.15))
                        .foregroundColor(.green)
                        .clipShape(Capsule())

                    if recipe.missedIngredientCount > 0 {
                        Text("\(recipe.missedIngredientCount) missing")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange.opacity(0.15))
                            .foregroundColor(.orange)
                            .clipShape(Capsule())
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Detail Sheet View
struct SpoonacularDetailSheet: View {
    let recipe: SpoonacularRecipe
    @Environment(\.dismiss) private var dismiss

    @State private var detail: SpoonacularDetail? = nil
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    AsyncImage(url: URL(string: recipe.image ?? "")) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 200)
                                .clipped()
                                .cornerRadius(16)
                        }
                    }

                    if let detail = detail {
                        HStack {
                            if let prep = detail.readyInMinutes {
                                Label("\(prep) mins", systemImage: "clock")
                            }
                            Spacer()
                            if let servings = detail.servings {
                                Label("\(servings) servings", systemImage: "person.2")
                            }
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(12)
                    }

                    // Ingredients Comparison
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Ingredients")
                            .font(.headline)

                        ForEach(recipe.usedIngredients) { item in
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text(item.original?.capitalized ?? item.name.capitalized)
                                    .font(.subheadline)
                                Spacer()
                                Text("In Fridge")
                                    .font(.caption2)
                                    .foregroundColor(.green)
                            }
                        }

                        ForEach(recipe.missedIngredients) { item in
                            HStack {
                                Image(systemName: "circle")
                                    .foregroundColor(.gray)
                                Text(item.original?.capitalized ?? item.name.capitalized)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("Missing")
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                            }
                        }
                    }

                    Divider()

                    // Cooking Instructions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Instructions")
                            .font(.headline)

                        if isLoading {
                            ProgressView("Loading cooking steps...")
                        } else if let steps = detail?.analyzedInstructions?.first?.steps, !steps.isEmpty {
                            ForEach(steps) { step in
                                HStack(alignment: .top, spacing: 12) {
                                    Text("\(step.number)")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .frame(width: 24, height: 24)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .clipShape(Circle())

                                    Text(step.step)
                                        .font(.subheadline)
                                }
                            }
                        } else if let rawText = detail?.instructions, !rawText.isEmpty {
                            Text(rawText.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression))
                                .font(.subheadline)
                        } else {
                            Text("No instructions provided for this recipe.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(recipe.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .task {
                do {
                    self.detail = try await SpoonacularService.shared.fetchRecipeDetail(id: recipe.id)
                } catch {
                    print("Failed to load details: \(error)")
                }
                self.isLoading = false
            }
        }
    }
}
