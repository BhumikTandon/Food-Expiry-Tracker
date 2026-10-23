//
//  SpoonacularService.swift
//  Food Expiry Tracker
//
//  Created by Ishanshika Arora on 10/23/26.
//

//  SpoonacularService.swift
//  Food Expiry Tracker

import Foundation

// MARK: - Spoonacular Data Models
struct SpoonacularRecipe: Identifiable, Codable {
    let id: Int
    let title: String
    let image: String?
    let usedIngredientCount: Int
    let missedIngredientCount: Int
    let usedIngredients: [SpoonacularIngredient]
    let missedIngredients: [SpoonacularIngredient]
}

struct SpoonacularIngredient: Codable, Identifiable {
    var id: String { original ?? name }
    let name: String
    let original: String?
    let image: String?
}

struct SpoonacularDetail: Codable {
    let id: Int
    let readyInMinutes: Int?
    let servings: Int?
    let instructions: String?
    let analyzedInstructions: [AnalyzedInstruction]?
}

struct AnalyzedInstruction: Codable {
    let steps: [InstructionStep]
}

struct InstructionStep: Codable, Identifiable {
    var id: Int { number }
    let number: Int
    let step: String
}

// MARK: - Spoonacular API Client
class SpoonacularService {
    static let shared = SpoonacularService()
    
    // ⚠️ Replace with your actual Spoonacular API Key
    private let apiKey = "46d5c2aabcb6422a9b17a9df13090eb2"
    private let baseURL = "https://api.spoonacular.com/recipes"
    
    /// Finds recipes using available ingredients from fridge
    func searchByIngredients(_ ingredients: [String], number: Int = 10) async throws -> [SpoonacularRecipe] {
        guard !ingredients.isEmpty else { return [] }
        
        let ingredientString = ingredients.joined(separator: ",").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "\(baseURL)/findByIngredients?ingredients=\(ingredientString)&number=\(number)&ranking=1&apiKey=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode([SpoonacularRecipe].self, from: data)
    }
    
    /// Fetches step-by-step instructions when a user taps a recipe card
    func fetchRecipeDetail(id: Int) async throws -> SpoonacularDetail {
        let urlString = "\(baseURL)/\(id)/information?includeNutrition=false&apiKey=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(SpoonacularDetail.self, from: data)
    }
}
