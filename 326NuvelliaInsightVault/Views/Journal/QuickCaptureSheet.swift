import SwiftUI

struct QuickCaptureSheet: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.vaultTheme) private var theme
    @Environment(\.dismiss) private var dismiss

    @State private var caption = ""
    @State private var mood: MoodTag?

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Quick Capture")
                    .font(.system(.title3, design: .serif).weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))

                TextField(
                    "",
                    text: $caption,
                    prompt: Text("What’s the scene?").foregroundColor(Color("AppTextSecondary")),
                    axis: .vertical
                )
                .lineLimit(3...6)
                .padding(14)
                .background(Color("AppSurface"))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .foregroundStyle(Color("AppTextPrimary"))
                .tint(theme.accent)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(MoodTag.allCases) { tag in
                            Button {
                                mood = mood == tag ? nil : tag
                                HapticFeedback.selection()
                            } label: {
                                Label(tag.title, systemImage: tag.symbol)
                                    .font(.caption.weight(.semibold))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 8)
                                    .foregroundStyle(Color("AppTextPrimary"))
                                    .background(mood == tag ? theme.primary.opacity(0.45) : Color("AppSurface"))
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                PrimaryButton(title: "Save") {
                    let trimmed = caption.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }
                    store.addJournalEntry(
                        JournalEntry(caption: trimmed, date: Date(), mood: mood?.rawValue)
                    )
                    dismiss()
                }
                .opacity(caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.45 : 1)
                .disabled(caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                Spacer(minLength: 0)
            }
            .padding(20)
            .dismissKeyboardOnTap()
            .storybookBackground()
            .vaultNavigationChrome()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
        }
        .presentationDetents([.medium])
    }
}
