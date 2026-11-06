
import Foundation

enum MealSuggestions {
    private static let breakfast = ["Pancake e Miele", "Yogurt & Avena", "Porridge Cacao", "Toast e Fesa", "Pancake e Miele", "Omelette Salata", "Yogurt & Noci"]
    private static let morningSnack = ["Mela & Mandorle", "Gallette & Bresaola", "Banana", "Kiwi & Noci", "Mela & Mandorle", "Yogurt Greco", "Gallette & Bresaola"]
    private static let lunch = ["Riso, Pollo e Zucchine", "Pasta Integrale e Tonno", "Farro con Verdure e Feta", "Risotto alle Zucchine", "Gnocchi al Pomodoro", "Insalata di Pollo", "Riso Venere e Gamberi"]
    private static let afternoonSnack = ["Shake Proteico", "Frutta Secca", "Yogurt Greco", "Shake Proteico", "Gallette e Tacchino", "Frutta di Stagione", "Yogurt Greco"]
    private static let dinner = ["Salmone e Patate", "Petto di Pollo e Insalata", "Orata al Forno e Verdure", "Tagliata di Manzo e Rucola", "Uova e Spinaci", "Frittata al Forno", "Merluzzo e Zucchine"]

    static func dishes(for meal: MealType, on date: Date) -> [String] {
        let i = DiaryStore.weekdayIndex(date)
        switch meal {
        case .breakfast: return [breakfast[i]]
        case .lunch:     return [lunch[i]]
        case .snack:     return [morningSnack[i], afternoonSnack[i]]
        case .dinner:    return [dinner[i]]
        }
    }
}
