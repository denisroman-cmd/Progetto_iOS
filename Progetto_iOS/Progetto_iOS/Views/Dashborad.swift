import SwiftUI

struct Dashboard: View {
    let profile: UserProfile
    @Binding var isRegistered: Bool
    @EnvironmentObject private var diary: DiaryStore

    @AppStorage("streakCount") private var streakCount = 1
    @AppStorage("lastLoginDate") private var lastLoginDate = ""

    private let shortDays = ["Lun", "Mar", "Mer", "Gio", "Ven", "Sab", "Dom"]

    private var totalCalories: Int {
        HealthCalculator.calculateDailyCalories(profile: profile)
    }

    private var proteinTarget: Double { Double(totalCalories) * 0.25 / 4.0 }
    private var carbsTarget: Double { Double(totalCalories) * 0.50 / 4.0 }
    private var fatTarget: Double { Double(totalCalories) * 0.25 / 9.0 }

    private var dayTotals: NutritionSummary { diary.total(for: diary.selectedDate) }

    private var weekDates: [Date] {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 2
        guard let interval = cal.dateInterval(of: .weekOfYear, for: Date()) else { return [] }
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: interval.start) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    streakBanner
                    dailyNeedCard
                    weekStrip
                    caloriesCard
                    mealsSection
                }
                .padding()
            }
            .navigationTitle("Ciao, \(profile.name.isEmpty ? "Utente" : profile.name)")
            .navigationDestination(for: MealType.self) { meal in
                MealDiaryView(meal: meal, dailyCalories: totalCalories)
            }
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

    // MARK: - Parti della schermata

    private var streakBanner: some View {
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
    }

    private var dailyNeedCard: some View {
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
    }

    private var weekStrip: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Questa settimana")
                .font(.title3)
                .bold()

            HStack(spacing: 6) {
                ForEach(weekDates, id: \.self) { date in
                    let isSelected = Calendar.current.isDate(date, inSameDayAs: diary.selectedDate)
                    let isToday = Calendar.current.isDateInToday(date)

                    Button {
                        diary.selectedDate = date
                    } label: {
                        VStack(spacing: 4) {
                            Text(shortDays[DiaryStore.weekdayIndex(date)])
                                .font(.caption2)
                            Text("\(Calendar.current.component(.day, from: date))")
                                .font(.headline)
                            Circle()
                                .fill(isToday ? (isSelected ? Color.white : Color.green) : Color.clear)
                                .frame(width: 5, height: 5)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(isSelected ? Color.green : Color(.secondarySystemBackground))
                        .foregroundColor(isSelected ? .white : .primary)
                        .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                }
            }

            Text(diary.selectedDate.italianLongDay)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private var caloriesCard: some View {
        let consumed = dayTotals.calories
        let progress = totalCalories > 0 ? consumed / Double(totalCalories) : 0

        return HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 10)
                Circle()
                    .trim(from: 0, to: min(progress, 1))
                    .stroke(progress > 1 ? Color.red : Color.green,
                            style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 2) {
                    Text("\(Int(consumed))")
                        .font(.title2)
                        .bold()
                    Text("/ \(totalCalories) kcal")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 110, height: 110)

            VStack(spacing: 8) {
                MacroBar(title: "Proteine", value: dayTotals.protein, target: proteinTarget, color: .blue)
                MacroBar(title: "Carboidrati", value: dayTotals.carbs, target: carbsTarget, color: .orange)
                MacroBar(title: "Grassi", value: dayTotals.fat, target: fatTarget, color: .red)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }

    private var mealsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(Calendar.current.isDateInToday(diary.selectedDate) ? "Pasti di oggi" : "Pasti del giorno")
                .font(.title3)
                .bold()
            Text("Tocca un pasto per aggiungere cosa hai mangiato")
                .font(.caption)
                .foregroundColor(.secondary)

            ForEach(MealType.allCases) { meal in
                mealRow(meal)
            }
        }
    }

    private func mealRow(_ meal: MealType) -> some View {
        let target = Double(HealthCalculator.caloriesForMeal(meal, totalCalories: totalCalories))
        let eaten = diary.total(for: diary.selectedDate, meal: meal).calories

        return NavigationLink(value: meal) {
            HStack(spacing: 12) {
                Image(systemName: meal.icon)
                    .font(.title3)
                    .foregroundColor(.green)
                    .frame(width: 36)

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(meal.rawValue)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                        Text("\(Int(eaten)) / \(Int(target)) kcal")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    ProgressView(value: min(eaten, max(target, 1)), total: max(target, 1))
                        .tint(eaten > target ? Color.red : Color.green)
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }

    private func checkAndUpdateStreak() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        let todayStr = formatter.string(from: Date())
        guard lastLoginDate != todayStr else { return }

        let cal = Calendar.current
        if let lastDate = formatter.date(from: lastLoginDate),
           let days = cal.dateComponents([.day],
                                         from: cal.startOfDay(for: lastDate),
                                         to: cal.startOfDay(for: Date())).day {
            streakCount = (days == 1) ? streakCount + 1 : 1
        } else {
            streakCount = 1   
        }
        lastLoginDate = todayStr
    }
}
