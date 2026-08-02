import StoreKit
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.vaultTheme) private var theme
    @State private var showResetAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Settings")
                    .font(.system(.largeTitle, design: .serif).weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .frame(maxWidth: .infinity, alignment: .leading)

                EditorialCard {
                    HStack(spacing: 12) {
                        Image(systemName: "flame.fill")
                            .font(.title2)
                            .foregroundStyle(theme.accent)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(store.currentStreak)-day writing streak")
                                .font(.headline)
                                .foregroundStyle(Color("AppTextPrimary"))
                            Text(store.currentStreak == 0
                                 ? "Write a narrative today to start a streak."
                                 : "Keep writing daily to protect the flame.")
                                .font(.caption)
                                .foregroundStyle(Color("AppTextSecondary"))
                        }
                    }
                }

                EditorialCard {
                    VStack(spacing: 0) {
                        Toggle(isOn: Binding(
                            get: { store.soundEnabled },
                            set: { store.setSoundEnabled($0) }
                        )) {
                            settingsLabel(title: "Sound Effects", icon: "speaker.wave.2.fill")
                        }
                        .tint(theme.primary)
                        .padding(.vertical, 10)

                        divider

                        Toggle(isOn: Binding(
                            get: { store.hapticsEnabled },
                            set: { store.setHapticsEnabled($0) }
                        )) {
                            settingsLabel(title: "Haptic Feedback", icon: "waveform")
                        }
                        .tint(theme.primary)
                        .padding(.vertical, 10)

                        divider

                        Toggle(isOn: Binding(
                            get: { store.remindersEnabled },
                            set: { store.setRemindersEnabled($0) }
                        )) {
                            settingsLabel(title: "Daily Writing Reminder", icon: "bell.fill")
                        }
                        .tint(theme.primary)
                        .padding(.vertical, 10)
                    }
                }

                EditorialCard {
                    VStack(spacing: 0) {
                        settingsRow(title: "Rate Us", icon: "star.fill") {
                            requestReview()
                        }
                        divider
                        settingsRow(title: "Privacy Policy", icon: "hand.raised.fill") {
                            openLink(AppLinks.privacy)
                        }
                        divider
                        settingsRow(title: "Terms of Use", icon: "doc.text.fill") {
                            openLink(AppLinks.terms)
                        }
                        divider
                        Button {
                            HapticFeedback.warning()
                            showResetAlert = true
                        } label: {
                            HStack {
                                Image(systemName: "trash.fill")
                                    .foregroundStyle(theme.accent)
                                    .frame(width: 28)
                                Text("Reset All Data")
                                    .foregroundStyle(Color("AppTextPrimary"))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(Color("AppTextSecondary"))
                            }
                            .padding(.vertical, 14)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 28)
        }
        .alert("Reset All Data?", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                store.resetAllData()
            }
        } message: {
            Text("This removes chapters, journal narratives, theme favorites, photos, and onboarding progress from this device.")
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(theme.primary.opacity(0.2))
            .frame(height: 1)
    }

    private func settingsLabel(title: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(theme.accent)
                .frame(width: 28)
            Text(title)
                .foregroundStyle(Color("AppTextPrimary"))
            Spacer()
        }
    }

    private func settingsRow(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button {
            HapticFeedback.lightTap()
            action()
        } label: {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(theme.accent)
                    .frame(width: 28)
                Text(title)
                    .foregroundStyle(Color("AppTextPrimary"))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }

    private func openLink(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }

    private func requestReview() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        SKStoreReviewController.requestReview(in: scene)
    }
}
