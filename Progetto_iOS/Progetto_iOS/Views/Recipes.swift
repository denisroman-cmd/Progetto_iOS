import SwiftUI

struct Recipes: View {
    @EnvironmentObject private var diary: DiaryStore

    @State private var recipes: [Recipe] = []
    @State private var searchQuery: String = "Pollo"
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedRecipeForDetails: Recipe?

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                HStack {
                    TextField("Cerca ricetta (es. Pasta, Riso...)", text: $searchQuery)
                        .textFieldStyle(.roundedBorder)
                        .submitLabel(.search)
                        .onSubmit { fetchRecipes() }

                    Button("Cerca") {
                        fetchRecipes()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal)
                .padding(.top)

                if isLoading {
                    Spacer()
                    ProgressView("Caricamento ricette...")
                    Spacer()
                } else if recipes.isEmpty {
                    Spacer()
                    Text(errorMessage ?? "Nessuna ricetta trovata.")
                        .foregroundColor(errorMessage == nil ? .gray : .red)
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()
                } else {
                    List(recipes) { recipe in
                        Button {
                            selectedRecipeForDetails = recipe
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "fork.knife")
                                    .font(.title2)
                                    .foregroundColor(.green)
                                    .frame(width: 50, height: 50)
                                    .background(Color.green.opacity(0.15))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(recipe.title)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                        .lineLimit(2)

                                    Text("\(recipe.caloriesPerServing) kcal / porzione")
                                        .font(.subheadline)
                                        .bold()
                                        .foregroundColor(.green)

                                    Text("P: \(recipe.proteinPerServing)g | C: \(recipe.carbsPerServing)g | G: \(recipe.fatPerServing)g")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Ricette Online")
            .sheet(item: $selectedRecipeForDetails) { recipe in
                RecipeDetailSheet(recipe: recipe)
                    .environmentObject(diary)
            }
            .onAppear {
                if recipes.isEmpty { fetchRecipes() }
            }
        }
    }

    private func fetchRecipes() {
        isLoading = true
        errorMessage = nil
        Task {
            recipes = await RecipeService.shared.searchRecipes(query: searchQuery)
            errorMessage = RecipeService.shared.lastError
            isLoading = false
        }
    }
}

struct RecipeDetailSheet: View {
    let recipe: Recipe

    @EnvironmentObject private var diary: DiaryStore
    @Environment(\.dismiss) private var dismiss

    @State private var meal: MealType = .lunch
    @State private var portions: Double = 1

    private var date: Date { diary.selectedDate }
    private var alreadyAdded: Bool { diary.hasRecipe(recipe.title, date: date, meal: meal) }

    private var totalForPortions: Int {
        let servings = Double(max(recipe.servings, 1))
        return Int((recipe.totalCalories / servings * portions).rounded())
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Valori per porzione (\(recipe.servings) porzioni totali)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    HStack(spacing: 12) {
                        MacroBadge(title: "Calorie", value: "\(recipe.caloriesPerServing) kcal", color: .green)
                        MacroBadge(title: "Proteine", value: "\(recipe.proteinPerServing)g", color: .blue)
                        MacroBadge(title: "Carbo", value: "\(recipe.carbsPerServing)g", color: .orange)
                        MacroBadge(title: "Grassi", value: "\(recipe.fatPerServing)g", color: .red)
                    }

                    addToDiaryCard

                    if !recipe.ingredients.isEmpty {
                        Text("Ingredienti:")
                            .font(.headline)

                        ForEach(recipe.ingredients, id: \.self) { ingredient in
                            Text("• \(ingredient)")
                                .font(.subheadline)
                        }
                    }

                    if !recipe.instructions.isEmpty {
                        Text("Istruzioni:")
                            .font(.headline)
                            .padding(.top, 8)

                        ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, step in
                            Text("\(index + 1). \(step)")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(recipe.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Chiudi") { dismiss() }
                }
            }
            .onAppear {
                meal = diary.preferredMeal ?? MealType.suggested(for: Date())
            }
        }
    }

    // MARK: - Aggiungi / rimuovi dal diario

    private var addToDiaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Aggiungi al diario")
                .font(.headline)

            Text(date.italianLongDay)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Picker("Pasto", selection: $meal) {
                ForEach(MealType.allCases) { m in
                    Text(m.rawValue).tag(m)
                }
            }
            .pickerStyle(.segmented)

            Stepper(value: $portions, in: 0.5...10, step: 0.5) {
                Text("Porzioni: \(String(format: "%g", portions)) (\(totalForPortions) kcal)")
                    .font(.subheadline)
            }
            .disabled(alreadyAdded)

            if alreadyAdded {
                Label("Già nel diario (\(meal.rawValue.lowercased()))", systemImage: "checkmark.circle.fill")
                    .font(.subheadline)
                    .foregroundColor(.green)

                Button(role: .destructive) {
                    diary.removeRecipe(recipe.title, date: date, meal: meal)
                } label: {
                    Label("Rimuovi dal diario", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button {
                    diary.selectedTab = 0
                    dismiss()
                } label: {
                    Label("Vai al piano", systemImage: "calendar")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button {
                    diary.addRecipe(recipe, portions: portions, date: date, meal: meal)
                    diary.preferredMeal = nil
                } label: {
                    Label("Aggiungi al diario", systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}
