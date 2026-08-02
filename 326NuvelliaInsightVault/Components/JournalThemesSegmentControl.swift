import SwiftUI

struct JournalThemesSegmentControl: View {
    @Binding var selection: JournalThemesSegment
    @Environment(\.vaultTheme) private var theme

    var body: some View {
        HStack(spacing: 0) {
            ForEach(JournalThemesSegment.allCases) { segment in
                let isSelected = selection == segment
                Button {
                    HapticFeedback.selection()
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selection = segment
                    }
                } label: {
                    Text(segment.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(isSelected ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            isSelected
                                ? AnyShapeStyle(
                                    LinearGradient(
                                        colors: [theme.primary.opacity(0.9), theme.accent.opacity(0.75)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                : AnyShapeStyle(Color.clear)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color("AppSurface").opacity(0.75))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(theme.primary.opacity(0.35), lineWidth: 1)
        )
    }
}
