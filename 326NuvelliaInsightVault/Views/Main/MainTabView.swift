import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var store: AppStore
    @State private var selectedTab: MainTab = .chapters
    @State private var journalSegment: JournalThemesSegment = .journal
    @State private var showJournalBridgeSheet = false
    @State private var bridgeCaption = ""

    var body: some View {
        VStack(spacing: 0) {
            MagazineTabBar(selection: $selectedTab)

            Group {
                switch selectedTab {
                case .chapters:
                    ChaptersView()
                case .journalThemes:
                    JournalThemesContainerView(segment: $journalSegment)
                case .statistics:
                    StatisticsView()
                case .achievements:
                    AchievementsView()
                case .settings:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .storybookBackground()
        .onChange(of: store.pendingChapterForJournal?.id) { _ in
            if store.pendingChapterForJournal != nil {
                bridgeCaption = ""
                showJournalBridgeSheet = true
            }
        }
        .sheet(isPresented: $showJournalBridgeSheet, onDismiss: {
            store.clearPendingChapterBridge()
        }) {
            JournalBridgeSheet(
                caption: $bridgeCaption,
                chapterTitle: store.pendingChapterForJournal?.title ?? "",
                onAdd: {
                    guard let chapter = store.pendingChapterForJournal else { return }
                    let trimmed = bridgeCaption.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }
                    store.addJournalEntry(
                        JournalEntry(caption: trimmed, date: Date(), chapterId: chapter.id)
                    )
                    store.clearPendingChapterBridge()
                    showJournalBridgeSheet = false
                    selectedTab = .journalThemes
                    journalSegment = .journal
                },
                onSkip: {
                    store.clearPendingChapterBridge()
                    showJournalBridgeSheet = false
                }
            )
            .presentationDetents([.medium])
        }
    }
}

private struct JournalBridgeSheet: View {
    @Binding var caption: String
    let chapterTitle: String
    let onAdd: () -> Void
    let onSkip: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Chapter Created")
                    .font(.system(.title3, design: .serif).weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
                Text("Add a journal narrative for \"\(chapterTitle)\"?")
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .multilineTextAlignment(.center)
                TextField(
                    "",
                    text: $caption,
                    prompt: Text("Caption").foregroundColor(Color("AppTextSecondary")),
                    axis: .vertical
                )
                .lineLimit(3...6)
                .padding(12)
                .background(Color("AppSurface"))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .foregroundStyle(Color("AppTextPrimary"))
                .tint(Color("AppAccent"))
                PrimaryButton(title: "Add Narrative", action: onAdd)
                    .opacity(caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.45 : 1)
                    .disabled(caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                Button("Not Now", action: onSkip)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            .padding(24)
            .dismissKeyboardOnTap()
            .storybookBackground()
            .vaultNavigationChrome()
        }
    }
}
