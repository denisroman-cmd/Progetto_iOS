import SwiftUI

struct NutritionSummary {
    var calories: Double = 0
    var protein: Double = 0
    var carbs: Double = 0
    var fat: Double = 0
}

struct LoggedFoodItem: Identifiable {
    let id = UUID()
    let name: String
    let amount: String
    let nutrition: NutritionSummary
}

struct Tracker: View {
    @State private var foodName: String = ""
    @State private var gramsText: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    @State private var loggedItems: [LoggedFoodItem] = []

    var totalCalories: Double { loggedItems.reduce(0) { $0 + $1.nutrition.calories } }
    var totalProtein: Double { loggedItems.reduce(0) { $0 + $1.nutrition.protein } }
    var totalCarbs: Double { loggedItems.reduce(0) { $0 + $1.nutrition.carbs } }
    var totalFat: Double { loggedItems.reduce(0) { $0 + $1.nutrition.fat } }

    private var grams: Double? {
        Double(gramsText.replacingOccurrences(of: ",", with: "."))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                HStack(spacing: 10) {
                    TrackerMacroCard(title: "Calorie", value: "\(Int(totalCalories)) kcal", color: .green)
                    TrackerMacroCard(title: "Proteine", value: "\(Int(totalProtein))g", color: .blue)
                    TrackerMacroCard(title: "Carbo", value: "\(Int(totalCarbs))g", color: .orange)
                    TrackerMacroCard(title: "Grassi", value: "\(Int(totalFat))g", color: .red)
                }
                .padding(.horizontal)

                VStack(spacing: 10) {
                    TextField("Alimento (es. Petto di Pollo)", text: $foodName)
                        .textFieldStyle(.roundedBorder)

                    TextField("Quantità in grammi (es. 150)", text: $gramsText)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                    }

                    Button(action: addFoodItem) {
                        if isLoading {
                            ProgressView().frame(maxWidth: .infinity)
                        } else {
                            Label("Calcola e aggiungi", systemImage: "plus.circle.fill")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(foodName.trimmingCharacters(in: .whitespaces).isEmpty
                              || (grams ?? 0) <= 0
                              || isLoading)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)

                List {
                    ForEach(loggedItems) { item in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(item.name) · \(item.amount)")
                                    .font(.headline)
                                Text("P: \(Int(item.nutrition.protein))g | C: \(Int(item.nutrition.carbs))g | G: \(Int(item.nutrition.fat))g")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text("\(Int(item.nutrition.calories)) kcal")
                                .bold()
                                .foregroundColor(.green)
                        }
                    }
                    .onDelete(perform: deleteItem)
                }
                .listStyle(.plain)
            }
            .navigationTitle("Diario Alimentare")
        }
    }

    private func addFoodItem() {
        guard let grams, grams > 0 else { return }
        let name = foodName.trimmingCharacters(in: .whitespaces)
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let nutrition = try await OpenFoodFactsService.shared.fetchNutrition(foodName: name, grams: grams)
                loggedItems.append(LoggedFoodItem(name: name.capitalized,
                                                  amount: "\(Int(grams)) g",
                                                  nutrition: nutrition))
                foodName = ""
                gramsText = ""
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    private func deleteItem(at offsets: IndexSet) {
        loggedItems.remove(atOffsets: offsets)
    }
}

struct TrackerMacroCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack {
            Text(title).font(.caption2).foregroundColor(.gray)
            Text(value).font(.caption).bold().foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
}
