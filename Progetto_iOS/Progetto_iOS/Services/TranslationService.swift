///limite 5000 caretter gionalieri
import Foundation

private struct MyMemoryResponse: Decodable {
    struct ResponseData: Decodable { let translatedText: String }
    let responseData: ResponseData
}


final class TranslationService {
    static let shared = TranslationService()
    private init() {}

    private var cache: [String: String] = [:]

    func toEnglish(_ text: String) async -> String {
        let clean = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !clean.isEmpty else { return text }
        if let cached = cache[clean] { return cached }

        var components = URLComponents(string: "https://api.mymemory.translated.net/get")
        components?.queryItems = [
            URLQueryItem(name: "q", value: clean),
            URLQueryItem(name: "langpair", value: "it|en")
        ]
        guard let url = components?.url else { return clean }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let result = try JSONDecoder().decode(MyMemoryResponse.self, from: data)
            let translated = result.responseData.translatedText
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .lowercased()
            guard !translated.isEmpty else { return clean }
            cache[clean] = translated
            return translated
        } catch {
            print("Traduzione fallita: \(error)")
            return clean
        }
    }
}
