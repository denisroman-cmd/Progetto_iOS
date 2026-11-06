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
    @State private var caloriesText: String = ""
    @State private var proteinText: String = ""
    @State private var carbsText: String = ""
    @State private var fatText: String = ""
    
    @State private var loggedItems: [LoggedFoodItem] = []
    
    var totalCalories: Double { loggedItems.reduce(0) { $0 + $1.nutrition.calories } }
    var totalProtein: Double { loggedItems.reduce(0) { $0 + $1.nutrition.protein } }
    var totalCarbs: Double { loggedItems.reduce(0) { $0 + $1.nutrition.carbs } }
    var totalFat: Double { loggedItems.reduce(0) { $0 + $1.nutrition.fat } }
    
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
                    TextField("Nome Alimento (es. Petto di Pollo)", text: $foodName)
                        .textFieldStyle(.roundedBorder)
                    
                    HStack(spacing: 8) {
                        TextField("kcal", text: $caloriesText)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                        TextField("Prot (g)", text: $proteinText)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                        TextField("Carb (g)", text: $carbsText)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                        TextField("Fat (g)", text: $fatText)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    Button(action: addFoodItem) {
                        Label("Aggiungi al Diario", systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(foodName.isEmpty || caloriesText.isEmpty)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
                
                List {
                    ForEach(loggedItems) { item in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.name)
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
        let cal = Double(caloriesText) ?? 0
        let p = Double(proteinText) ?? 0
        let c = Double(carbsText) ?? 0
        let f = Double(fatText) ?? 0
        
        let summary = NutritionSummary(calories: cal, protein: p, carbs: c, fat: f)
        let newItem = LoggedFoodItem(name: foodName, amount: "", nutrition: summary)
        
        loggedItems.append(newItem)
        
        foodName = ""
        caloriesText = ""
        proteinText = ""
        carbsText = ""
        fatText = ""
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
