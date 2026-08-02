import SwiftUI

struct ContentView: View {
    @StateObject private var store = AppStore()

    var body: some View {
        Group {
            if store.hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .environmentObject(store)
        .environment(\.vaultTheme, store.vaultTheme)
        .preferredColorScheme(.dark)
        .tint(store.vaultTheme.accent)
    }
}
