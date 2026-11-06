import SwiftUI

struct Dashboard: View {
    let profile: UserProfile
    @Binding var isRegistered: Bool
    
    @AppStorage("streakCount") private var streakCount = 1
    @AppStorage("lastLoginDate") private var lastLoginDate = ""
    
    var totalCalories: Int {
        HealthCalculator.calculateDailyCalories(profile: profile)
    }
    
    let daysOfWeek = ["Lunedì", "Martedì", "Mercoledì", "Giovedì", "Venerdì", "Sabato", "Domenica"]
    
    let weeklyMenu: [MealType: [String]] = [
        .breakfast: ["Pancake e Miele", "Yogurt & Avena", "Porridge Cacao", "Toast e Fesa", "Pancake e Miele", "Omelette Salata", "Yogurt & Noci"],
        .morningSnack: ["Mela & Mandorle", "Gallette & Bresaola", "Banana", "Kiwi & Noci", "Mela & Mandorle", "Yogurt Greco", "Gallette & Bresaola"],
        .lunch: ["Riso, Pollo e Zucchine", "Pasta Integrale e Tonno", "Farro con Verdure e Feta", "Risotto alle Zucchine", "Gnocchi al Pomodoro", "Insalata di Pollo", "Riso Venere e Gamberi"],
        .afternoonSnack: ["Shake Proteico", "Frutta Secca", "Yogurt Greco", "Shake Proteico", "Gallette e Tacchino", "Frutta di Stagione", "Yogurt Greco"],
        .dinner: ["Salmone e Patate", "Petto di Pollo e Insalata", "Orata al Forno e Verdure", "Tagliata di Manzo e Rucola", "Uova e Spinaci", "Frittata al Forno", "Merluzzo e Zucchine"]
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("Stai seguendo la dieta da **\(streakCount) giorni**!")
                            .font(.headline)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange.opacity(0.15))
                    .cornerRadius(12)
                    
                    VStack {
                        Text("Il tuo Fabbisogno Giornaliero")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("\(totalCalories) kcal")
                            .font(.system(size: 38, weight: .bold))
                            .foregroundColor(.green)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Piano Alimentare Settimanale")
                            .font(.title3)
                            .bold()
                        
                        ScrollView(.horizontal, showsIndicators: true) {
                            Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 12) {
                                GridRow {
                                    Text("Pasto / Giorno")
                                        .bold()
                                        .padding(8)
                                        .frame(width: 140, alignment: .leading)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(6)
                                    
                                    ForEach(daysOfWeek, id: \.self) { day in
                                        Text(day)
                                            .bold()
                                            .padding(8)
                                            .frame(width: 160, alignment: .center)
                                            .background(Color.green.opacity(0.2))
                                            .cornerRadius(6)
                                    }
                                }
                                
                                Divider()
                                
                                ForEach(MealType.allCases) { meal in
                                    GridRow {
                                        VStack(alignment: .leading) {
                                            Text(meal.rawValue)
                                                .bold()
                                                .font(.subheadline)
                                            Text("~\(HealthCalculator.caloriesForMeal(meal, totalCalories: totalCalories)) kcal")
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(8)
                                        .frame(width: 140, alignment: .leading)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(6)
                                        
                                        if let mealList = weeklyMenu[meal] {
                                            ForEach(0..<7, id: \.self) { dayIndex in
                                                Text(mealList[dayIndex])
                                                    .font(.caption)
                                                    .multilineTextAlignment(.center)
                                                    .padding(8)
                                                    .frame(width: 160, height: 50)
                                                    .background(Color(.tertiarySystemBackground))
                                                    .cornerRadius(6)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 6)
                                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                                    )
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 5)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Ciao, \(profile.name.isEmpty ? "Utente" : profile.name)")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .destructive) {
                        isRegistered = false
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Esci")
                        }
                    }
                }
            }
            .onAppear(perform: checkAndUpdateStreak)
        }
    }
    
    private func checkAndUpdateStreak() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayStr = formatter.string(from: Date())
        if lastLoginDate != todayStr {
            if let lastDate = formatter.date(from: lastLoginDate),
               let days = Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day, days == 1 {
                streakCount += 1
            } else if lastLoginDate.isEmpty {
                streakCount = 1
            }
            lastLoginDate = todayStr
        }
    }
}
