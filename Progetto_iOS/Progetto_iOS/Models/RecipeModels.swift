
import Foundation

private extension KeyedDecodingContainer {
    func flexibleDouble(forKey key: Key) -> Double {
        if let d = try? decode(Double.self, forKey: key) { return d }
        if let s = try? decode(String.self, forKey: key), let d = Double(s) { return d }
        return 0
    }
}

struct Recipe: Decodable, Identifiable {
    let id = UUID()
    let title: String
    let servings: Int
    let ingredients: [String]
    let instructions: [String]

    let totalCalories: Double
    let totalProtein: Double
    let totalCarbs: Double
    let totalFat: Double

    var caloriesPerServing: Int { Int((totalCalories / Double(servings)).rounded()) }
    var proteinPerServing: Int { Int((totalProtein / Double(servings)).rounded()) }
    var carbsPerServing: Int { Int((totalCarbs / Double(servings)).rounded()) }
    var fatPerServing: Int { Int((totalFat / Double(servings)).rounded()) }

    private enum CodingKeys: String, CodingKey {
        case title, servings, ingredients, instructions, nutrition
    }

    private struct IngredientDTO: Decodable {
        let name: String
        let quantity: Double
        let unit: String

        enum CodingKeys: String, CodingKey { case name, quantity, unit }

        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            name = (try? c.decode(String.self, forKey: .name)) ?? ""
            quantity = c.flexibleDouble(forKey: .quantity)
            unit = (try? c.decode(String.self, forKey: .unit)) ?? ""
        }

        var formatted: String {
            let q = quantity > 0 ? String(format: "%g", (quantity * 100).rounded() / 100) : ""
            let u = (unit.lowercased() == "unit") ? "" : unit
            let n = name.replacingOccurrences(of: ";", with: ",")
            return [q, u, n].filter { !$0.isEmpty }.joined(separator: " ")
        }
    }

    private struct NutritionDTO: Decodable {
        let calories: Double
        let protein: Double
        let fat: Double
        let carbs: Double

        enum CodingKeys: String, CodingKey {
            case calories, protein
            case fat = "total_fat"
            case carbs = "total_carbohydrate"
        }

        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            calories = c.flexibleDouble(forKey: .calories)
            protein = c.flexibleDouble(forKey: .protein)
            fat = c.flexibleDouble(forKey: .fat)
            carbs = c.flexibleDouble(forKey: .carbs)
        }
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        title = (try? c.decode(String.self, forKey: .title)) ?? "Ricetta"

        let servingsText: String
        if let s = try? c.decode(String.self, forKey: .servings) {
            servingsText = s
        } else if let n = try? c.decode(Int.self, forKey: .servings) {
            servingsText = "\(n)"
        } else {
            servingsText = ""
        }
        let firstNumber = servingsText
            .split(whereSeparator: { !$0.isNumber })
            .first
            .flatMap { Int($0) } ?? 1
        servings = max(1, firstNumber)

        let ingredientDTOs = (try? c.decode([IngredientDTO].self, forKey: .ingredients)) ?? []
        ingredients = ingredientDTOs.map { $0.formatted }.filter { !$0.isEmpty }

        if let steps = try? c.decode([String].self, forKey: .instructions) {
            instructions = steps
        } else if let text = try? c.decode(String.self, forKey: .instructions) {
            instructions = [text]
        } else {
            instructions = []
        }

        let n = try? c.decode(NutritionDTO.self, forKey: .nutrition)
        totalCalories = n?.calories ?? 0
        totalProtein = n?.protein ?? 0
        totalCarbs = n?.carbs ?? 0
        totalFat = n?.fat ?? 0
    }
}
