

import SwiftUI

struct MealDiaryView: View {
    let meal: MealType
    let dailyCalories: Int

    @EnvironmentObject private var diary: DiaryStore

    @State private var foodName = ""
    @State private var gramsText = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    private var date: Date { diary.selectedDate }
    private var target: Int { HealthCalculator.caloriesForMeal(meal, totalCalories: dailyCalories) }
    private var entries: [FoodEntry] { diary.entries(for: date, meal: meal) }
    private var eaten: Double { diary.total(for: date, meal: meal).calories }
    private var dishes: [String] { MealSuggestions.dishes(for: meal, on: date) }
    private var suggestionAccepted: Bool { diary.hasSuggestion(for: date, meal: meal) }
    private var grams: Double? { Double(gramsText.replacingOccurrences(of: ",", with: ".")) }

    var body: some View {
        List {
            // Riepilogo
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(date.italianLongDay)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    HStack {
                        Text("\(Int(eaten)) / \(target) kcal")
                            .font(.title2)
                            .bold()
                            .foregroundColor(eaten > Double(target) ? .red : .green)
                        Spacer()
                        Text(eaten <= Double(target)
                             ? "Rimaste \(target - Int(eaten)) kcal"
                             : "Superato di \(Int(eaten) - target) kcal")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    ProgressView(value: min(eaten, Double(max(target, 1))), total: Double(max(target, 1)))
                        .tint(eaten > Double(target) ? Color.red : Color.green)
                }
                .padding(.vertical, 4)
            }

            // Consiglio
            Section {
                ForEach(dishes, id: \.self) { dish in
                    Label(dish, systemImage: "fork.knife")
                }

                if suggestionAccepted {
                    Label("Consiglio aggiunto al diario", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    Button {
                        diary.addSuggestions(dishes, date: date, meal: meal, mealCalories: target)
                    } label: {
                        Label("Accetta il consiglio (~\(target) kcal)", systemImage: "plus.circle.fill")
                    }
                }
            } header: {
                Text("Consiglio per \(meal.rawValue.lowercased())")
            } footer: {
                Text("Se accetti, i valori nutrizionali sono una stima basata sul target del pasto.")
            }

            // Aggiunta manuale
            Section("Aggiungi alimento") {
                TextField("Alimento (es. Petto di pollo)", text: $foodName)
                TextField("Quantità in grammi (es. 150)", text: $gramsText)
                    .keyboardType(.decimalPad)

                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                }

                Button(action: addManualFood) {
                    if isLoading {
                        ProgressView().frame(maxWidth: .infinity)
                    } else {
                        Label("Calcola e aggiungi", systemImage: "plus.circle.fill")
                    }
                }
                .disabled(foodName.trimmingCharacters(in: .whitespaces).isEmpty
                          || (grams ?? 0) <= 0
                          || isLoading)
            }

            // Ricette
            Section {
                Button {
                    diary.preferredMeal = meal
                    diary.selectedTab = 1
                } label: {
                    Label("Cerca una ricetta", systemImage: "book.fill")
                }
            } footer: {
                Text("Apri una ricetta e scegli \"Aggiungi al diario\".")
            }

            Section {
                if entries.isEmpty {
                    Text("Ancora niente.")
                        .foregroundColor(.secondary)
                }
                ForEach(entries) { item in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(item.name) · \(item.amount)")
                                .font(.headline)
                            Text("P: \(Int(item.protein))g | C: \(Int(item.carbs))g | G: \(Int(item.fat))g\(item.isSuggestion ? " · stima" : "")\(item.recipeTitle != nil ? " · ricetta" : "")")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text("\(Int(item.calories)) kcal")
                            .bold()
                            .foregroundColor(.green)
                    }
                }
                .onDelete { offsets in
                    diary.remove(at: offsets, from: entries)
                }
            } header: {
                Text("Mangiato a \(meal.rawValue.lowercased())")
            } footer: {
                if !entries.isEmpty {
                    Text("Scorri a sinistra su un alimento (o tocca Modifica) per toglierlo.")
                }
            }
        }
        .navigationTitle(meal.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !entries.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
        }
    }

    private func addManualFood() {
        guard let grams, grams > 0 else { return }
        let name = foodName.trimmingCharacters(in: .whitespaces)
        let day = date
        let currentMeal = meal
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let n = try await OpenFoodFactsService.shared.fetchNutrition(foodName: name, grams: grams)
                await MainActor.run {
                    diary.add(FoodEntry(
                        dayKey: DiaryStore.dayKey(day),
                        meal: currentMeal,
                        name: name.capitalized,
                        amount: "\(Int(grams)) g",
                        calories: n.calories,
                        protein: n.protein,
                        carbs: n.carbs,
                        fat: n.fat
                    ))
                    foodName = ""
                    gramsText = ""
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}
