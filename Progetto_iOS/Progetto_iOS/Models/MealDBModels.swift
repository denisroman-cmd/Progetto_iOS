import Foundation

struct MealDBResponse: Decodable {
    let meals: [MealDBRecipe]?
}

struct MealDBRecipe: Decodable, Identifiable {
    var id: String { idMeal }
    let idMeal: String
    let strMeal: String
    let strMealThumb: String
    let strInstructions: String?
    let ingredientsList: [String]

    private struct DynamicKey: CodingKey {
        var stringValue: String
        var intValue: Int? { nil }
        init(_ string: String) { stringValue = string }
        init?(stringValue: String) { self.stringValue = stringValue }
        init?(intValue: Int) { return nil }
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: DynamicKey.self)
        idMeal = try c.decode(String.self, forKey: DynamicKey("idMeal"))
        strMeal = try c.decode(String.self, forKey: DynamicKey("strMeal"))
        strMealThumb = (try? c.decode(String.self, forKey: DynamicKey("strMealThumb"))) ?? ""
        strInstructions = try? c.decodeIfPresent(String.self, forKey: DynamicKey("strInstructions"))

        // TheMealDB ha fino a 20 ingredienti (strIngredient1...20)
        var list: [String] = []
        for i in 1...20 {
            let ing = ((try? c.decodeIfPresent(String.self, forKey: DynamicKey("strIngredient\(i)"))) ?? nil)?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard !ing.isEmpty else { continue }
            let meas = ((try? c.decodeIfPresent(String.self, forKey: DynamicKey("strMeasure\(i)"))) ?? nil)?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            list.append(meas.isEmpty ? ing : "\(meas) \(ing)")
        }
        ingredientsList = list
    }

    // Stima approssimativa e STABILE (hashValue cambiava a ogni avvio)
    var estimatedCalories: Int {
        let stable = idMeal.unicodeScalars.reduce(0) { $0 + Int($1.value) } % 100
        return min(max(250 + ingredientsList.count * 25 + stable, 280), 750)
    }
    var estimatedProtein: Int { Int(Double(estimatedCalories) * 0.25 / 4.0) }
    var estimatedCarbs: Int { Int(Double(estimatedCalories) * 0.50 / 4.0) }
    var estimatedFat: Int { Int(Double(estimatedCalories) * 0.25 / 9.0) }
}
