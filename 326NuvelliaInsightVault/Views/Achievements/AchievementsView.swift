import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.vaultTheme) private var theme

    private var definitions: [AchievementDefinition] {
        AchievementDefinition.all()
    }

    private var unlockedCount: Int {
        definitions.filter { $0.isUnlocked(store.snapshot) }.count
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Achievements")
                    .font(.system(.largeTitle, design: .serif).weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))

                EditorialCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(unlockedCount) of \(definitions.count) unlocked")
                            .font(.headline)
                            .foregroundStyle(theme.accent)
                        ProgressView(value: Double(unlockedCount), total: Double(definitions.count))
                            .tint(theme.primary)
                    }
                }

                EditorialCard {
                    VStack(spacing: 4) {
                        ForEach(definitions) { definition in
                            AchievementRow(
                                definition: definition,
                                unlocked: definition.isUnlocked(store.snapshot)
                            )
                            if definition.id != definitions.last?.id {
                                Divider()
                                    .overlay(theme.primary.opacity(0.25))
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 28)
        }
    }
}
