import Foundation

final class RecipeService {
    static let shared = RecipeService()
    private init() {}

    private(set) var lastError: String?

    private let targetCount = 10

    private let extraKeywords = ["salad", "soup", "baked", "pasta"]

    func searchRecipes(query: String) async -> [Recipe] {
        lastError = nil
        let clean = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let english = await TranslationService.shared.toEnglish(clean.isEmpty ? "chicken" : clean)

        var results: [Recipe] = []
        var seenTitles = Set<String>()

        func add(_ newRecipes: [Recipe]) {
            for recipe in newRecipes {
                let key = recipe.title.lowercased()
                if !seenTitles.contains(key) {
                    seenTitles.insert(key)
                    results.append(recipe)
                }
            }
        }

        var first = await fetch(title: english)

        if first.isEmpty, lastError == nil, english.contains(" "),
           let word = english.split(separator: " ").max(by: { $0.count < $1.count }) {
            first = await fetch(title: String(word))
        }
        add(first)

   
        if first.count >= 5 {
            for keyword in extraKeywords {
                if results.count >= targetCount { break }
                // evita "pasta pasta", "rice rice"...
                if english.lowercased().contains(keyword) { continue }
                add(await fetch(title: "\(english) \(keyword)"))
            }
        }

        if !results.isEmpty { lastError = nil }
        return results
    }

    private func fetch(title: String) async -> [Recipe] {
        var components = URLComponents(string: "https://api.api-ninjas.com/v3/recipe")
        components?.queryItems = [
            URLQueryItem(name: "title", value: title),
            URLQueryItem(name: "limit", value: "5")   
        ]
        guard let url = components?.url else { return [] }

        var request = URLRequest(url: url)
        request.timeoutInterval = 20
        request.setValue(APIConfig.apiNinjasKey, forHTTPHeaderField: "X-Api-Key")

        for attempt in 1...3 {
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                let status = (response as? HTTPURLResponse)?.statusCode ?? 0

                switch status {
                case 200:
                    lastError = nil
                    return try JSONDecoder().decode([Recipe].self, from: data)
                case 401, 403:
                    lastError = "API key non valida o non autorizzata."
                case 429:
                    lastError = "Hai raggiunto il limite di richieste di API Ninjas."
                default:
                    lastError = "Errore del server (codice \(status))."
                }
                return []
            } catch let error as URLError {
                print("Tentativo \(attempt) fallito: \(error)")
                lastError = "Impossibile collegarsi ad API Ninjas. Controlla la connessione o prova un'altra rete."
                try? await Task.sleep(nanoseconds: 700_000_000)
            } catch {
                print("Errore di decodifica: \(error)")
                lastError = "Risposta non valida dal server."
                return []
            }
        }
        return []
    }
}
