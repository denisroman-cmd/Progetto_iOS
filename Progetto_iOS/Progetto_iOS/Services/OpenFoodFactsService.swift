
import Foundation

enum OpenFoodFactsError: LocalizedError {
    case invalidURL
    case badStatus(Int)
    case noResults

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Richiesta non valida."
        case .badStatus(let code): return "Errore del server (codice \(code)). Riprova tra poco."
        case .noResults: return "Alimento non trovato. Prova con un nome più semplice (es. \"pollo\")."
        }
    }
}

private struct OFFSearchResponse: Decodable {
    let products: [OFFProduct]
}

private struct OFFProduct: Decodable {
    let productName: String?
    let nutriments: OFFNutriments?

    enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case nutriments
    }
}

private struct OFFNutriments: Decodable {
    let kcal100: Double
    let protein100: Double
    let carbs100: Double
    let fat100: Double

    private struct Key: CodingKey {
        var stringValue: String
        var intValue: Int? { nil }
        init?(stringValue: String) { self.stringValue = stringValue }
        init?(intValue: Int) { return nil }
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: Key.self)
        func value(_ name: String) -> Double {
            guard let key = Key(stringValue: name) else { return 0 }
            if let d = try? c.decode(Double.self, forKey: key) { return d }
            if let s = try? c.decode(String.self, forKey: key), let d = Double(s) { return d }
            return 0
        }
        kcal100 = value("energy-kcal_100g")
        protein100 = value("proteins_100g")
        carbs100 = value("carbohydrates_100g")
        fat100 = value("fat_100g")
    }
}


final class OpenFoodFactsService {
    static let shared = OpenFoodFactsService()
    private init() {}

    func fetchNutrition(foodName: String, grams: Double) async throws -> NutritionSummary {
        var components = URLComponents(string: "https://world.openfoodfacts.org/cgi/search.pl")
        components?.queryItems = [
            URLQueryItem(name: "search_terms", value: foodName),
            URLQueryItem(name: "search_simple", value: "1"),
            URLQueryItem(name: "action", value: "process"),
            URLQueryItem(name: "json", value: "1"),
            URLQueryItem(name: "page_size", value: "20"),
            URLQueryItem(name: "lc", value: "it"),
            URLQueryItem(name: "fields", value: "product_name,nutriments")
        ]
        guard let url = components?.url else { throw OpenFoodFactsError.invalidURL }

        var request = URLRequest(url: url)
        request.timeoutInterval = 20
        request.setValue("Progetto_iOS - StudentApp", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await URLSession.shared.data(for: request)
        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            throw OpenFoodFactsError.badStatus(http.statusCode)
        }

        let decoded = try JSONDecoder().decode(OFFSearchResponse.self, from: data)

        guard let n = decoded.products.compactMap({ $0.nutriments }).first(where: { $0.kcal100 > 0 }) else {
            throw OpenFoodFactsError.noResults
        }

        let factor = grams / 100.0
        return NutritionSummary(
            calories: n.kcal100 * factor,
            protein: n.protein100 * factor,
            carbs: n.carbs100 * factor,
            fat: n.fat100 * factor
        )
    }
}
