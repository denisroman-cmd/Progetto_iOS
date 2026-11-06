import SwiftUI

struct Recipes: View {
    @State private var recipes: [MealDBRecipe] = []
    @State private var searchQuery: String = "Chicken"
    @State private var isLoading = false
    @State private var selectedRecipeForDetails: MealDBRecipe?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                HStack {
                    TextField("Cerca ricetta (es. Pasta, Rice...)", text: $searchQuery)
                        .textFieldStyle(.roundedBorder)
                    
                    Button("Cerca") {
                        fetchRecipes()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal)
                .padding(.top)
                
                if isLoading {
                    Spacer()
                    ProgressView("Caricamento da TheMealDB...")
                    Spacer()
                } else if recipes.isEmpty {
                    Spacer()
                    Text("Nessuna ricetta trovata.")
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    List(recipes) { recipe in
                        Button {
                            selectedRecipeForDetails = recipe
                        } label: {
                            HStack(spacing: 12) {
                                AsyncImage(url: URL(string: recipe.strMealThumb)) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    Color.gray.opacity(0.3)
                                }
                                .frame(width: 70, height: 70)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(recipe.strMeal)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text("~ \(recipe.estimatedCalories) kcal")
                                        .font(.subheadline)
                                        .bold()
                                        .foregroundColor(.green)
                                    
                                    Text("P: \(recipe.estimatedProtein)g | C: \(recipe.estimatedCarbs)g | G: \(recipe.estimatedFat)g")
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
            }
            .onAppear {
                if recipes.isEmpty { fetchRecipes() }
            }
        }
    }
    
    private func fetchRecipes() {
        isLoading = true
        Task {
            recipes = await MealDBService.shared.searchRecipes(query: searchQuery)
            isLoading = false
        }
    }
}

struct RecipeDetailSheet: View {
    let recipe: MealDBRecipe
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    AsyncImage(url: URL(string: recipe.strMealThumb)) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(12)
                    
                    HStack(spacing: 12) {
                        MacroBadge(title: "Calorie", value: "\(recipe.estimatedCalories) kcal", color: .green)
                        MacroBadge(title: "Proteine", value: "\(recipe.estimatedProtein)g", color: .blue)
                        MacroBadge(title: "Carbo", value: "\(recipe.estimatedCarbs)g", color: .orange)
                        MacroBadge(title: "Grassi", value: "\(recipe.estimatedFat)g", color: .red)
                    }
                    
                    Text("Ingredienti:")
                        .font(.headline)
                    
                    ForEach(recipe.ingredientsList, id: \.self) { ingredient in
                        Text("• \(ingredient)")
                            .font(.subheadline)
                    }
                    
                    if let instructions = recipe.strInstructions, !instructions.isEmpty {
                        Text("Istruzioni:")
                            .font(.headline)
                            .padding(.top, 8)
                        
                        Text(instructions)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle(recipe.strMeal)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Chiudi") { dismiss() }
                }
            }
        }
    }
}

struct MacroBadge: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack {
            Text(title).font(.caption2).foregroundColor(.gray)
            Text(value).font(.caption).bold().foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
}
