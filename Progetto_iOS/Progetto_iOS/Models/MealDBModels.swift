import Foundation

struct MealDBResponse: Codable {
    let meals: [MealDBRecipe]?
}

struct MealDBRecipe: Codable, Identifiable {
    var id: String { idMeal }
    let idMeal: String
    let strMeal: String
    let strMealThumb: String
    let strInstructions: String?
    
    let strIngredient1: String?
    let strIngredient2: String?
    let strIngredient3: String?
    let strIngredient4: String?
    let strIngredient5: String?
    
    let strMeasure1: String?
    let strMeasure2: String?
    let strMeasure3: String?
    let strMeasure4: String?
    let strMeasure5: String?
    
    var ingredientsList: [String] {
        let ingredients = [strIngredient1, strIngredient2, strIngredient3, strIngredient4, strIngredient5]
        let measures = [strMeasure1, strMeasure2, strMeasure3, strMeasure4, strMeasure5]
        
        var list: [String] = []
        for (ing, meas) in zip(ingredients, measures) {
            if let ingredient = ing?.trimmingCharacters(in: .whitespacesAndNewlines), !ingredient.isEmpty {
                let measure = meas?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                if measure.isEmpty {
                    list.append(ingredient)
                } else {
                    list.append("\(measure) \(ingredient)")
                }
            }
        }
        return list
    }
    
    var estimatedCalories: Int {
        let base = 350
        let extra = (ingredientsList.count * 40) + (abs(idMeal.hashValue) % 120)
        return min(max(base + extra, 280), 750)
    }
    
    var estimatedProtein: Int { Int(Double(estimatedCalories) * 0.25 / 4.0) }
    var estimatedCarbs: Int { Int(Double(estimatedCalories) * 0.50 / 4.0) }
    var estimatedFat: Int { Int(Double(estimatedCalories) * 0.25 / 9.0) }
}
