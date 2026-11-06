

import Foundation
import SwiftUI

final class DiaryStore: ObservableObject {
    @Published var entries: [FoodEntry] = []
    @Published var selectedDate: Date = Date()
    @Published var preferredMeal: MealType?
    @Published var selectedTab: Int = 0

    private var storageKey: String {
        "diaryEntries_" + (UserDefaults.standard.string(forKey: "currentEmail") ?? "")
    }

    func reload() {
        entries = []
        load()
    }

    init() { load() }


    private static let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    static func dayKey(_ date: Date) -> String { dayFormatter.string(from: date) }

    static func weekdayIndex(_ date: Date) -> Int {
        (Calendar.current.component(.weekday, from: date) + 5) % 7
    }


    func entries(for date: Date, meal: MealType? = nil) -> [FoodEntry] {
        let key = Self.dayKey(date)
        return entries.filter { $0.dayKey == key && (meal == nil || $0.meal == meal) }
    }

    func total(for date: Date, meal: MealType? = nil) -> NutritionSummary {
        let list = entries(for: date, meal: meal)
        return NutritionSummary(
            calories: list.reduce(0) { $0 + $1.calories },
            protein: list.reduce(0) { $0 + $1.protein },
            carbs: list.reduce(0) { $0 + $1.carbs },
            fat: list.reduce(0) { $0 + $1.fat }
        )
    }

    func hasSuggestion(for date: Date, meal: MealType) -> Bool {
        entries(for: date, meal: meal).contains { $0.isSuggestion }
    }

    func hasRecipe(_ title: String, date: Date, meal: MealType) -> Bool {
        entries(for: date, meal: meal).contains { $0.recipeTitle == title }
    }


    func add(_ entry: FoodEntry) {
        entries.append(entry)
        save()
    }

    func remove(at offsets: IndexSet, from list: [FoodEntry]) {
        let ids = offsets.map { list[$0].id }
        entries.removeAll { ids.contains($0.id) }
        save()
    }

    func addRecipe(_ recipe: Recipe, portions: Double, date: Date, meal: MealType) {
        let servings = Double(max(recipe.servings, 1))
        let amount = portions == 1 ? "1 porzione" : "\(String(format: "%g", portions)) porzioni"
        entries.append(FoodEntry(
            dayKey: Self.dayKey(date),
            meal: meal,
            name: recipe.title,
            amount: amount,
            calories: recipe.totalCalories / servings * portions,
            protein: recipe.totalProtein / servings * portions,
            carbs: recipe.totalCarbs / servings * portions,
            fat: recipe.totalFat / servings * portions,
            recipeTitle: recipe.title
        ))
        save()
    }

    func removeRecipe(_ title: String, date: Date, meal: MealType) {
        let key = Self.dayKey(date)
        entries.removeAll { $0.dayKey == key && $0.meal == meal && $0.recipeTitle == title }
        save()
    }

   
    func addSuggestions(_ dishes: [String], date: Date, meal: MealType, mealCalories: Int) {
        guard !dishes.isEmpty else { return }
        let each = Double(mealCalories) / Double(dishes.count)
        for dish in dishes {
            entries.append(FoodEntry(
                dayKey: Self.dayKey(date),
                meal: meal,
                name: dish,
                amount: "1 porzione",
                calories: each,
                protein: each * 0.25 / 4.0,
                carbs: each * 0.50 / 4.0,
                fat: each * 0.25 / 9.0,
                isSuggestion: true
            ))
        }
        save()
    }


    private func save() {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([FoodEntry].self, from: data) else { return }
        entries = decoded
    }
}

extension Date {
    var italianLongDay: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "it_IT")
        f.dateFormat = "EEEE d MMMM"
        let s = f.string(from: self)
        return s.prefix(1).uppercased() + s.dropFirst()
    }
}
