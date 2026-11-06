//
//  Diarymodels.swift
//  Progetto_iOS
//
//  Created by s11 on 06/11/26.
//

import Foundation

struct NutritionSummary {
    var calories: Double = 0
    var protein: Double = 0
    var carbs: Double = 0
    var fat: Double = 0
}

struct FoodEntry: Identifiable, Codable {
    var id = UUID()
    var dayKey: String
    var meal: MealType
    var name: String
    var amount: String
    var calories: Double
    var protein: Double
    var carbs: Double
    var fat: Double
    var isSuggestion: Bool = false   
    var recipeTitle: String? = nil
}
