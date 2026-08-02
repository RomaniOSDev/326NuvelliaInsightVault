import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    @Environment(\.vaultTheme) private var theme

    var body: some View {
        Button(action: {
            HapticFeedback.lightTap()
            action()
        }) {
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(Color("AppTextPrimary"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [theme.primary, theme.accent],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(color: theme.primary.opacity(0.45), radius: 12, y: 6)
        }
        .buttonStyle(.plain)
    }
}
