import SwiftUI

struct ContentView: View {
    @AppStorage("isRegistered") private var isRegistered = false
    @State private var userProfile = UserProfile.load()
    @StateObject private var diary = DiaryStore()

    
    private var registeredBinding: Binding<Bool> {
        Binding(
            get: { isRegistered },
            set: { newValue in
                if newValue {
                    userProfile.save()
                    diary.reload()
                }
                isRegistered = newValue
            }
        )
    }

    var body: some View {
        Group {
            if !isRegistered {
                Login(profile: $userProfile, isRegistered: registeredBinding)
            } else {
                TabView(selection: $diary.selectedTab) {
                    Dashboard(profile: userProfile, isRegistered: $isRegistered)
                        .tabItem {
                            Image(systemName: "calendar")
                            Text("Piano")
                        }
                        .tag(0)

                    Recipes()
                        .tabItem {
                            Image(systemName: "book.fill")
                            Text("Ricette Online")
                        }
                        .tag(1)
                }
                .environmentObject(diary)
            }
        }
        .onChange(of: isRegistered) { _, newValue in
            if !newValue {
                UserDefaults.standard.removeObject(forKey: "currentEmail")
                userProfile = UserProfile()                  
                diary.reload()
            }
        }
    }
}
