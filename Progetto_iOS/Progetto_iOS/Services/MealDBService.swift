
import Foundation

class MealDBService {
    static let shared = MealDBService()
    
    private init() {}
    
    func searchRecipes(query: String = "chicken") async -> [MealDBRecipe] {
        let cleanQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let searchQuery = cleanQuery.isEmpty ? "chicken" : cleanQuery
        
        guard let encodedQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://www.themealdb.com/api/json/v1/1/search.php?s=\(encodedQuery)") else {
            return []
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return []
            }
            
            let decodedResponse = try JSONDecoder().decode(MealDBResponse.self, from: data)
            return decodedResponse.meals ?? []
        } catch {
            print("Errore nella ricerca ricette: \(error)")
            return []
        }
    }
}
