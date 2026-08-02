import SwiftUI

struct ThemesView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.vaultTheme) private var theme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Theme Collections")
                    .font(.system(.largeTitle, design: .serif).weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
                Text("Favorite a palette, then apply it as your session accent.")
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))

                if store.appliedThemeId != nil {
                    Button {
                        store.applyTheme(id: nil)
                    } label: {
                        Label("Reset to default accents", systemImage: "arrow.counterclockwise")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color("AppTextPrimary"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color("AppSurface"))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }

                LazyVStack(spacing: 14) {
                    ForEach(ThemeCatalog.collections) { collection in
                        themeCard(collection)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 4)
            .padding(.bottom, 28)
        }
    }

    private func themeCard(_ collection: ThemeCollection) -> some View {
        let isFavorite = store.isThemeFavorite(collection.id)
        let isApplied = store.appliedThemeId == collection.id
        return EditorialCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    Text(collection.icon)
                        .font(.largeTitle)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(collection.title)
                            .font(.system(.title3, design: .serif).weight(.semibold))
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text(collection.subtitle)
                            .font(.subheadline)
                            .foregroundStyle(Color("AppTextSecondary"))
                        HStack {
                            ForEach(collection.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption2.weight(.semibold))
                                    .foregroundStyle(theme.accent)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color("AppBackground").opacity(0.5))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    Spacer(minLength: 0)
                    Button {
                        store.toggleThemeFavorite(collection.id)
                    } label: {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.title3)
                            .foregroundStyle(isFavorite ? theme.primary : Color("AppTextSecondary"))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(isFavorite ? "Unfavorite" : "Favorite")
                }

                HStack(spacing: 8) {
                    Circle().fill(Color(hex: collection.primaryHex)).frame(width: 16, height: 16)
                    Circle().fill(Color(hex: collection.accentHex)).frame(width: 16, height: 16)
                    Spacer()
                    Button {
                        store.applyTheme(id: isApplied ? nil : collection.id)
                    } label: {
                        Text(isApplied ? "Applied" : "Apply accents")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color("AppTextPrimary"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(isApplied ? theme.primary.opacity(0.45) : Color("AppSurface"))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
