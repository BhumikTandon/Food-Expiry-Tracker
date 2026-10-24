//
//  SpoonacularService.swift
//  Food Expiry Tracker
//
//  Created by Ishanshika Arora on 10/23/26.
//

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

// MARK: - Errors

enum SpoonacularError: LocalizedError {
    case missingAPIKey
    case badStatus(Int)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Add your Spoonacular API key to Secrets.swift."
        case .badStatus(401), .badStatus(403):
            return "Spoonacular rejected the API key."
        case .badStatus(402):
            return "The daily Spoonacular limit was reached. Try again tomorrow."
        case .badStatus(let code):
            return "Spoonacular returned an error (\(code))."
        }
    }
}

// MARK: - Spoonacular API Client
class SpoonacularService {
    static let shared = SpoonacularService()

    private let baseURL = "https://api.spoonacular.com/recipes"

    /// The key comes from the gitignored Secrets.swift and is sent as a header, so it never appears in a URL or log.
    private func makeRequest(path: String, queryItems: [URLQueryItem]) throws -> URLRequest {
        let key = Secrets.spoonacularApiKey
        guard !key.isEmpty, !key.hasPrefix("YOUR_") else { throw SpoonacularError.missingAPIKey }

        guard var components = URLComponents(string: "\(baseURL)\(path)") else { throw URLError(.badURL) }
        components.queryItems = queryItems
        guard let url = components.url else { throw URLError(.badURL) }

        var request = URLRequest(url: url)
        request.setValue(key, forHTTPHeaderField: "x-api-key")
        return request
    }

    private func send(_ request: URLRequest) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        guard http.statusCode == 200 else { throw SpoonacularError.badStatus(http.statusCode) }
        return data
    }

    /// Keeps letters, digits, spaces and hyphens so names like "mac & cheese" can't break the query.
    static func sanitized(_ name: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: " -"))
        let cleaned = String(name.unicodeScalars.filter { allowed.contains($0) })
        return cleaned
            .split(separator: " ", omittingEmptySubsequences: true)
            .joined(separator: " ")
            .lowercased()
    }

    /// Finds recipes using available ingredients from fridge
    func searchByIngredients(_ ingredients: [String], number: Int = 10) async throws -> [SpoonacularRecipe] {
        let names = ingredients.map(SpoonacularService.sanitized).filter { !$0.isEmpty }
        guard !names.isEmpty else { return [] }

        let request = try makeRequest(path: "/findByIngredients", queryItems: [
            URLQueryItem(name: "ingredients", value: names.joined(separator: ",")),
            URLQueryItem(name: "number", value: String(number)),
            URLQueryItem(name: "ranking", value: "1")
        ])
        return try JSONDecoder().decode([SpoonacularRecipe].self, from: try await send(request))
    }

    /// Fetches step-by-step instructions when a user taps a recipe card
    func fetchRecipeDetail(id: Int) async throws -> SpoonacularDetail {
        let request = try makeRequest(path: "/\(id)/information", queryItems: [
            URLQueryItem(name: "includeNutrition", value: "false")
        ])
        return try JSONDecoder().decode(SpoonacularDetail.self, from: try await send(request))
    }
}
