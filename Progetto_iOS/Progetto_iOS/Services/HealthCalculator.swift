import Foundation

struct HealthCalculator {
    static func calculateDailyCalories(profile: UserProfile) -> Int {
        var bmr = (10.0 * profile.weight) + (6.25 * profile.height) - (5.0 * Double(profile.age))
        bmr += profile.isMale ? 5 : -161
        var tdee = bmr * 1.375
        if profile.goal == "Dimagrire" {
            tdee -= 400
        } else if profile.goal == "Prendere peso" {
            tdee += 300
        }
        return Int(tdee)
    }

    static func caloriesForMeal(_ meal: MealType, totalCalories: Int) -> Int {
        let total = Double(totalCalories)
        switch meal {
        case .breakfast: return Int(total * 0.20)
        case .lunch:     return Int(total * 0.35)
        case .snack:     return Int(total * 0.20)
        case .dinner:    return Int(total * 0.25)
        }
    }
}
