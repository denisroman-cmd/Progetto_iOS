import Foundation

class MealDBService {
    static let shared = MealDBService()
    private init() {}

    private let base = "https://www.themealdb.com/api/json/v1/1"

    func searchRecipes(query: String = "chicken") async -> [MealDBRecipe] {
        let clean = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let english = await TranslationService.shared.toEnglish(clean.isEmpty ? "chicken" : clean)

        let byName = await fetch(path: "search.php", item: "s", value: english)
        if !byName.isEmpty { return byName }

        let basic = await fetch(path: "filter.php", item: "i", value: english.replacingOccurrences(of: " ", with: "_"))
        let limited = Array(basic.prefix(10))

        return await withTaskGroup(of: (Int, MealDBRecipe?).self) { group in
            for (index, meal) in limited.enumerated() {
                group.addTask {
                    let detail = await self.fetch(path: "lookup.php", item: "i", value: meal.idMeal)
                    return (index, detail.first ?? meal)
                }
            }
            var results: [(Int, MealDBRecipe)] = []
            for await (index, recipe) in group {
                if let recipe { results.append((index, recipe)) }
            }
            return results.sorted { $0.0 < $1.0 }.map { $0.1 }
        }
    }

    private func fetch(path: String, item: String, value: String) async -> [MealDBRecipe] {
        var components = URLComponents(string: "\(base)/\(path)")
        components?.queryItems = [URLQueryItem(name: item, value: value)]
        guard let url = components?.url else { return [] }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { return [] }
            return try JSONDecoder().decode(MealDBResponse.self, from: data).meals ?? []
        } catch {
            print("Errore nella ricerca ricette: \(error)")
            return []
        }
    }
}
