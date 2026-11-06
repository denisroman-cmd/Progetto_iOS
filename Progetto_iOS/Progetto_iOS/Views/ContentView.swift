import SwiftUI

struct ContentView: View {
    @AppStorage("isRegistered") private var isRegistered = false
    @State private var userProfile = UserProfile()
    
    var body: some View {
        if !isRegistered {
            Login(profile: $userProfile, isRegistered: $isRegistered)
        } else {
            TabView {
                Dashboard(profile: userProfile, isRegistered: $isRegistered)
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("Piano")
                    }
                
                Recipes()
                    .tabItem {
                        Image(systemName: "book.fill")
                        Text("Ricette Online")
                    }
                
                Tracker()
                    .tabItem {
                        Image(systemName: "plus.circle.fill")
                        Text("Diario Alimentare")
                    }
            }
        }
    }
}
