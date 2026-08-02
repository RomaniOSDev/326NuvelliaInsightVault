import SwiftUI

struct MagazineTabBar: View {
    @Binding var selection: MainTab
    @Environment(\.vaultTheme) private var theme

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(MainTab.allCases) { tab in
                    let isSelected = selection == tab
                    Button {
                        HapticFeedback.selection()
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                            selection = tab
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: tab.systemImage)
                                .font(.caption.weight(.bold))
                            Text(tab.title)
                                .font(.subheadline.weight(.semibold))
                        }
                        .foregroundStyle(isSelected ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            Capsule(style: .continuous)
                                .fill(
                                    isSelected
                                        ? LinearGradient(
                                            colors: [theme.primary, theme.accent],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                        : LinearGradient(
                                            colors: [Color("AppSurface").opacity(0.85), Color("AppSurface").opacity(0.65)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                )
                        )
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(theme.primary.opacity(isSelected ? 0 : 0.35), lineWidth: 1)
                        )
                        .shadow(color: isSelected ? theme.primary.opacity(0.4) : .clear, radius: 10, y: 4)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
        .background {
            Color("AppBackground")
                .overlay {
                    Image("bgStorybook")
                        .resizable()
                        .scaledToFill()
                        .opacity(0.3)
                        .clipped()
                }
                .ignoresSafeArea(edges: .top)
        }
    }
}
