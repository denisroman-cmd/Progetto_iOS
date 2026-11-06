import Foundation

struct UserProfile: Codable {
    var name: String = ""
    var isMale: Bool = true
    var age: Int = 25
    var weight: Double = 70.0
    var height: Double = 170.0
    var goal: String = "Dimagrire"
    var email: String = ""
    var password: String = ""
    var isDarkMode: Bool = false

    private enum CodingKeys: String, CodingKey {
        case name, isMale, age, weight, height, goal, email
    }

    static func normalized(_ email: String) -> String {
        email.trimmingCharacters(in: .whitespaces).lowercased()
    }

    static func exists(email: String) -> Bool {
        UserDefaults.standard.data(forKey: "profile_" + normalized(email)) != nil
    }

    static func load() -> UserProfile {
        let email = UserDefaults.standard.string(forKey: "currentEmail") ?? ""
        return load(email: email) ?? UserProfile()
    }

    static func load(email: String) -> UserProfile? {
        guard let data = UserDefaults.standard.data(forKey: "profile_" + normalized(email)),
              let profile = try? JSONDecoder().decode(UserProfile.self, from: data) else {
            return nil
        }
        return profile
    }

    static func checkLogin(email: String, password: String) -> UserProfile? {
        let e = normalized(email)
        let savedPassword = UserDefaults.standard.string(forKey: "password_" + e)
        guard savedPassword == password, let profile = load(email: e) else { return nil }
        return profile
    }

    func save() {
        let e = Self.normalized(email)
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: "profile_" + e)
        }
        UserDefaults.standard.set(password, forKey: "password_" + e)
        UserDefaults.standard.set(e, forKey: "currentEmail")   // account attivo
    }
}
