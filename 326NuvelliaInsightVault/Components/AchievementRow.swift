import SwiftUI

struct AchievementRow: View {
    let definition: AchievementDefinition
    let unlocked: Bool
    @Environment(\.vaultTheme) private var theme

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        unlocked
                            ? LinearGradient(
                                colors: [theme.primary, theme.accent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(
                                colors: [Color("AppSurface"), Color("AppSurface").opacity(0.6)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                    )
                    .frame(width: 48, height: 48)
                Image(systemName: definition.systemImage)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(unlocked ? Color("AppTextPrimary") : Color("AppTextSecondary"))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(definition.title)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                Text(definition.detail)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            Spacer()
            Image(systemName: unlocked ? "checkmark.seal.fill" : "lock.fill")
                .foregroundStyle(unlocked ? theme.accent : Color("AppTextSecondary").opacity(0.6))
        }
        .padding(.vertical, 6)
    }
}
