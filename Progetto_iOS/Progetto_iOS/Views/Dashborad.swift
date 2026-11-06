import SwiftUI

// MARK: - Modelli Dati per la Dashboard

struct Ingredient: Identifiable {
    let id = UUID()
    let name: String
    let amount: String
}

struct MealDetail {
    let title: String
    let ingredients: [Ingredient]
}

enum DashboardViewMode: String, CaseIterable, Identifiable {
    case daily = "Oggi"
    case weekly = "Tutta la Settimana"
    
    var id: String { rawValue }
}

// MARK: - Vista Dashboard

struct Dashboard: View {
    let profile: UserProfile
    @Binding var isRegistered: Bool
    
    @AppStorage("streakCount") private var streakCount = 1
    @AppStorage("lastLoginDate") private var lastLoginDate = ""
    
    @State private var viewMode: DashboardViewMode = .daily
    @State private var selectedDayIndex: Int = 0
    
    var totalCalories: Int {
        HealthCalculator.calculateDailyCalories(profile: profile)
    }
    
    let daysOfWeek = ["Lunedì", "Martedì", "Mercoledì", "Giovedì", "Venerdì", "Sabato", "Domenica"]
    let shortDaysOfWeek = ["LUN", "MAR", "MER", "GIO", "VEN", "SAB", "DOM"]
    
    // MARK: - Database Menu Settimanale con Ingredienti e Grammature Esatte
    let weeklyMenu: [MealType: [MealDetail]] = [
        .breakfast: [
            // Lunedì
            MealDetail(title: "Pancake al Miele", ingredients: [
                Ingredient(name: "Farina d'Avena", amount: "60g"),
                Ingredient(name: "Albume d'Uovo", amount: "150g"),
                Ingredient(name: "Miele", amount: "15g")
            ]),
            // Martedì
            MealDetail(title: "Yogurt & Avena", ingredients: [
                Ingredient(name: "Yogurt Greco 0%", amount: "170g"),
                Ingredient(name: "Fiocchi d'Avena", amount: "50g"),
                Ingredient(name: "Miele", amount: "10g")
            ]),
            // Mercoledì
            MealDetail(title: "Porridge Cacao e Mirtilli", ingredients: [
                Ingredient(name: "Fiocchi d'Avena", amount: "50g"),
                Ingredient(name: "Latte Parzialmente Scremato", amount: "200ml"),
                Ingredient(name: "Cacao Amaro", amount: "10g"),
                Ingredient(name: "Mirtilli", amount: "60g")
            ]),
            // Giovedì
            MealDetail(title: "Toast Integrale e Fesa", ingredients: [
                Ingredient(name: "Pane Integrale", amount: "60g (2 fette)"),
                Ingredient(name: "Fesa di Tacchino", amount: "60g"),
                Ingredient(name: "Olio EVO", amount: "5g")
            ]),
            // Venerdì
            MealDetail(title: "Pancake Proteici", ingredients: [
                Ingredient(name: "Farina d'Avena", amount: "60g"),
                Ingredient(name: "Albume d'Uovo", amount: "150g"),
                Ingredient(name: "Marmellata Light", amount: "20g")
            ]),
            // Sabato
            MealDetail(title: "Omelette Salata", ingredients: [
                Ingredient(name: "Uova Intere", amount: "2 medie (110g)"),
                Ingredient(name: "Spinaci Freschi", amount: "100g"),
                Ingredient(name: "Olio EVO", amount: "5g")
            ]),
            // Domenica
            MealDetail(title: "Yogurt Greco e Noci", ingredients: [
                Ingredient(name: "Yogurt Greco 0%", amount: "170g"),
                Ingredient(name: "Noci Sgusciate", amount: "20g"),
                Ingredient(name: "Miele", amount: "10g")
            ])
        ],
        
        .morningSnack: [
            MealDetail(title: "Mela e Mandorle", ingredients: [
                Ingredient(name: "Mela", amount: "150g (1 media)"),
                Ingredient(name: "Mandorle", amount: "15g")
            ]),
            MealDetail(title: "Gallette e Bresaola", ingredients: [
                Ingredient(name: "Gallette di Riso", amount: "30g (3 gallette)"),
                Ingredient(name: "Bresaola IGP", amount: "40g")
            ]),
            MealDetail(title: "Banana e Burro d'Arachidi", ingredients: [
                Ingredient(name: "Banana", amount: "120g"),
                Ingredient(name: "Burro d'Arachidi 100%", amount: "15g")
            ]),
            MealDetail(title: "Kiwi e Noci", ingredients: [
                Ingredient(name: "Kiwi", amount: "130g (2 piccoli)"),
                Ingredient(name: "Noci Sgusciate", amount: "15g")
            ]),
            MealDetail(title: "Mela e Mandorle", ingredients: [
                Ingredient(name: "Mela", amount: "150g"),
                Ingredient(name: "Mandorle", amount: "15g")
            ]),
            MealDetail(title: "Yogurt Greco Light", ingredients: [
                Ingredient(name: "Yogurt Greco 0%", amount: "150g"),
                Ingredient(name: "Miele", amount: "10g")
            ]),
            MealDetail(title: "Gallette e Bresaola", ingredients: [
                Ingredient(name: "Gallette di Riso", amount: "30g"),
                Ingredient(name: "Bresaola IGP", amount: "40g")
            ])
        ],
        
        .lunch: [
            MealDetail(title: "Riso, Pollo e Zucchine", ingredients: [
                Ingredient(name: "Riso Basmati", amount: "80g (a crudo)"),
                Ingredient(name: "Petto di Pollo", amount: "150g"),
                Ingredient(name: "Zucchine", amount: "200g"),
                Ingredient(name: "Olio EVO", amount: "10g (1 cucchiaio)")
            ]),
            MealDetail(title: "Pasta Integrale al Tonno", ingredients: [
                Ingredient(name: "Pasta Integrale", amount: "80g"),
                Ingredient(name: "Tonno al Naturale", amount: "112g (2 scatolette)"),
                Ingredient(name: "Pomodorini", amount: "150g"),
                Ingredient(name: "Olio EVO", amount: "10g")
            ]),
            MealDetail(title: "Farro con Verdure e Feta", ingredients: [
                Ingredient(name: "Farro", amount: "80g"),
                Ingredient(name: "Feta Light", amount: "50g"),
                Ingredient(name: "Verdure Grigliate", amount: "200g"),
                Ingredient(name: "Olio EVO", amount: "10g")
            ]),
            MealDetail(title: "Risotto alle Zucchine", ingredients: [
                Ingredient(name: "Riso Carnaroli", amount: "80g"),
                Ingredient(name: "Zucchine", amount: "200g"),
                Ingredient(name: "Parmigiano Reggiano", amount: "15g"),
                Ingredient(name: "Olio EVO", amount: "10g")
            ]),
            MealDetail(title: "Gnocchi al Pomodoro", ingredients: [
                Ingredient(name: "Gnocchi di Patate", amount: "200g"),
                Ingredient(name: "Passata di Pomodoro", amount: "150g"),
                Ingredient(name: "Mozzarella Light", amount: "60g"),
                Ingredient(name: "Olio EVO", amount: "5g")
            ]),
            MealDetail(title: "Insalata di Pollo e Crostini", ingredients: [
                Ingredient(name: "Petto di Pollo", amount: "160g"),
                Ingredient(name: "Lattuga / Insalata", amount: "150g"),
                Ingredient(name: "Pane Integrale Tostato", amount: "40g"),
                Ingredient(name: "Olio EVO", amount: "10g")
            ]),
            MealDetail(title: "Riso Venere e Gamberi", ingredients: [
                Ingredient(name: "Riso Venere", amount: "80g"),
                Ingredient(name: "Gamberi sgusciati", amount: "150g"),
                Ingredient(name: "Zucchine", amount: "150g"),
                Ingredient(name: "Olio EVO", amount: "10g")
            ])
        ],
        
        .afternoonSnack: [
            MealDetail(title: "Shake Proteico alla Banana", ingredients: [
                Ingredient(name: "Proteine del Siero", amount: "30g"),
                Ingredient(name: "Latte di Mandorla", amount: "200ml"),
                Ingredient(name: "Banana", amount: "100g")
            ]),
            MealDetail(title: "Frutta Secca e Parmigiano", ingredients: [
                Ingredient(name: "Parmigiano Reggiano", amount: "25g"),
                Ingredient(name: "Noci", amount: "15g")
            ]),
            MealDetail(title: "Yogurt Greco e Mirtilli", ingredients: [
                Ingredient(name: "Yogurt Greco 0%", amount: "150g"),
                Ingredient(name: "Mirtilli Freschi", amount: "80g")
            ]),
            MealDetail(title: "Shake Proteico", ingredients: [
                Ingredient(name: "Proteine del Siero", amount: "30g"),
                Ingredient(name: "Latte di Mandorla", amount: "200ml")
            ]),
            MealDetail(title: "Gallette e Tacchino", ingredients: [
                Ingredient(name: "Gallette di Riso", amount: "30g"),
                Ingredient(name: "Fesa di Tacchino", amount: "50g")
            ]),
            MealDetail(title: "Frutta Fresca e Noci", ingredients: [
                Ingredient(name: "Arancia", amount: "200g"),
                Ingredient(name: "Noci Sgusciate", amount: "15g")
            ]),
            MealDetail(title: "Yogurt Greco e Miele", ingredients: [
                Ingredient(name: "Yogurt Greco 0%", amount: "150g"),
                Ingredient(name: "Miele", amount: "10g")
            ])
        ],
        
        .dinner: [
            MealDetail(title: "Salmone e Patate al Vapore", ingredients: [
                Ingredient(name: "Filetto di Salmone", amount: "150g"),
                Ingredient(name: "Patate Lesse", amount: "200g"),
                Ingredient(name: "Broccoli Lessi", amount: "150g"),
                Ingredient(name: "Olio EVO", amount: "10g")
            ]),
            MealDetail(title: "Petto di Pollo e Insalata", ingredients: [
                Ingredient(name: "Petto di Pollo", amount: "180g"),
                Ingredient(name: "Insalata Mista", amount: "150g"),
                Ingredient(name: "Pane Integrale", amount: "50g"),
                Ingredient(name: "Olio EVO", amount: "10g")
            ]),
            MealDetail(title: "Orata al Forno e Verdure", ingredients: [
                Ingredient(name: "Filetto di Orata", amount: "180g"),
                Ingredient(name: "Zucchine e Melanzane", amount: "250g"),
                Ingredient(name: "Olio EVO", amount: "10g")
            ]),
            MealDetail(title: "Tagliata di Manzo e Rucola", ingredients: [
                Ingredient(name: "Lombo di Manzo", amount: "180g"),
                Ingredient(name: "Rucola Fresca", amount: "50g"),
                Ingredient(name: "Scaglie di Parmigiano", amount: "15g"),
                Ingredient(name: "Olio EVO", amount: "10g")
            ]),
            MealDetail(title: "Uova e Spinaci Lessi", ingredients: [
                Ingredient(name: "Uova Intere", amount: "2 medie (110g)"),
                Ingredient(name: "Spinaci Lessi", amount: "200g"),
                Ingredient(name: "Pane Integrale", amount: "50g"),
                Ingredient(name: "Olio EVO", amount: "10g")
            ]),
            MealDetail(title: "Frittata al Forno con Zucchine", ingredients: [
                Ingredient(name: "Uova Intere", amount: "2 medie"),
                Ingredient(name: "Zucchine", amount: "150g"),
                Ingredient(name: "Insalata Verde", amount: "100g"),
                Ingredient(name: "Olio EVO", amount: "10g")
            ]),
            MealDetail(title: "Merluzzo e Patate", ingredients: [
                Ingredient(name: "Filetto di Merluzzo", amount: "200g"),
                Ingredient(name: "Patate al Forno", amount: "180g"),
                Ingredient(name: "Zucchine", amount: "150g"),
                Ingredient(name: "Olio EVO", amount: "10g")
            ])
        ]
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // MARK: - Header Status & Calorie
                    HStack(spacing: 12) {
                        HStack {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                            Text("**\(streakCount)** gg")
                                .font(.subheadline)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.orange.opacity(0.15))
                        .cornerRadius(20)
                        
                        Spacer()
                        
                        HStack {
                            Text("Target:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(totalCalories) kcal")
                                .font(.subheadline)
                                .bold()
                                .foregroundColor(.green)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.green.opacity(0.15))
                        .cornerRadius(20)
                    }
                    .padding(.horizontal)
                    
                    // MARK: - Selettore Modalità (Oggi / Settimana)
                    Picker("Vista", selection: $viewMode) {
                        ForEach(DashboardViewMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // MARK: - VISTA GIORNALIERA CON GRAMMATURE
                    if viewMode == .daily {
                        VStack(spacing: 16) {
                            
                            // Barre Pillole dei Giorni
                            HStack(spacing: 8) {
                                ForEach(0..<7, id: \.self) { index in
                                    let isSelected = selectedDayIndex == index
                                    Button {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedDayIndex = index
                                        }
                                    } label: {
                                        VStack(spacing: 4) {
                                            Text(shortDaysOfWeek[index])
                                                .font(.caption2)
                                                .bold()
                                            Text("\(index + 1)")
                                                .font(.headline)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(isSelected ? Color.green : Color(.tertiarySystemBackground))
                                        .foregroundColor(isSelected ? .white : .primary)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(isSelected ? Color.green : Color.gray.opacity(0.2), lineWidth: 1)
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            // Titolo Giorno
                            HStack {
                                Text(daysOfWeek[selectedDayIndex])
                                    .font(.title2)
                                    .bold()
                                Spacer()
                                Text("Grammature e Ingredienti")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal)
                            
                            // Cards dei Pasti con Ingredienti e Quantità
                            VStack(spacing: 14) {
                                ForEach(MealType.allCases) { meal in
                                    let mealCalories = HealthCalculator.caloriesForMeal(meal, totalCalories: totalCalories)
                                    let mealDetail = weeklyMenu[meal]?[selectedDayIndex] ?? MealDetail(title: "Non specificato", ingredients: [])
                                    
                                    VStack(alignment: .leading, spacing: 12) {
                                        
                                        // Header Pasto
                                        HStack(spacing: 12) {
                                            Image(systemName: iconForMeal(meal))
                                                .font(.title3)
                                                .foregroundColor(.green)
                                                .frame(width: 36, height: 36)
                                                .background(Color.green.opacity(0.12))
                                                .clipShape(Circle())
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(meal.rawValue.uppercased())
                                                    .font(.caption2)
                                                    .bold()
                                                    .foregroundColor(.secondary)
                                                Text(mealDetail.title)
                                                    .font(.headline)
                                            }
                                            
                                            Spacer()
                                            
                                            Text("~\(mealCalories) kcal")
                                                .font(.caption)
                                                .bold()
                                                .foregroundColor(.green)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color.green.opacity(0.1))
                                                .cornerRadius(8)
                                        }
                                        
                                        Divider()
                                        
                                        // Lista Dettagliata Ingredienti + Grammature
                                        VStack(spacing: 6) {
                                            ForEach(mealDetail.ingredients) { ingr in
                                                HStack {
                                                    Text("• \(ingr.name)")
                                                        .font(.subheadline)
                                                        .foregroundColor(.primary)
                                                    Spacer()
                                                    Text(ingr.amount)
                                                        .font(.subheadline)
                                                        .bold()
                                                        .foregroundColor(.green)
                                                }
                                            }
                                        }
                                    }
                                    .padding()
                                    .background(Color(.secondarySystemBackground))
                                    .cornerRadius(16)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // MARK: - VISTA SETTIMANALE PER LA SPESA
                    else {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "cart.fill")
                                    .foregroundColor(.blue)
                                Text("Panoramica Settimanale per la Spesa")
                                    .font(.headline)
                            }
                            
                            Text("Scorri orizzontalmente per vedere piatti e ingredienti di ogni giorno:")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
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
                                                .frame(width: 200, alignment: .center)
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
                                                    let detail = mealList[dayIndex]
                                                    VStack(alignment: .leading, spacing: 4) {
                                                        Text(detail.title)
                                                            .font(.caption)
                                                            .bold()
                                                            .foregroundColor(.green)
                                                        
                                                        ForEach(detail.ingredients) { ing in
                                                            Text("• \(ing.name): **\(ing.amount)**")
                                                                .font(.system(size: 10))
                                                                .foregroundColor(.secondary)
                                                        }
                                                    }
                                                    .padding(8)
                                                    .frame(width: 200, alignment: .leading)
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
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
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
            .onAppear {
                checkAndUpdateStreak()
                setTodayAsSelected()
            }
        }
    }
    
    private func setTodayAsSelected() {
        let weekday = Calendar.current.component(.weekday, from: Date())
        let index = (weekday + 5) % 7
        selectedDayIndex = index
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
    
    private func iconForMeal(_ meal: MealType) -> String {
        switch meal {
        case .breakfast: return "cup.and.saucer.fill"
        case .morningSnack: return "apple.logo"
        case .lunch: return "fork.knife"
        case .afternoonSnack: return "leaf.fill"
        case .dinner: return "moon.stars.fill"
        }
    }
}
