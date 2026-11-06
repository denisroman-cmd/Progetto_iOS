
import Foundation

enum MealType: String, CaseIterable, Identifiable, Codable, Hashable {
    case breakfast = "Colazione"
    case lunch = "Pranzo"
    case snack = "Spuntino"
    case dinner = "Cena"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .breakfast: return "sunrise.fill"
        case .lunch:     return "sun.max.fill"
        case .snack:     return "cup.and.saucer.fill"
        case .dinner:    return "moon.stars.fill"
        }
    }

    static func suggested(for date: Date) -> MealType {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 5..<11:  return .breakfast
        case 11..<15: return .lunch
        case 15..<18: return .snack
        default:      return .dinner
        }
    }
}
