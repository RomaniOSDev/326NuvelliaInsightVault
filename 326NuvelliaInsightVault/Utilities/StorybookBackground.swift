import SwiftUI

extension View {
    func storybookBackground() -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                ZStack {
                    Color("AppBackground")
                    Image("bgStorybook")
                        .resizable()
                        .scaledToFill()
                        .opacity(0.3)
                }
                .ignoresSafeArea()
            }
    }

    func vaultNavigationChrome() -> some View {
        preferredColorScheme(.dark)
            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
