import SwiftUI

struct ChaptersView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.vaultTheme) private var theme
    @State private var showEditor = false
    @State private var showTimeline = false
    @State private var editingChapter: StoryChapter?
    @State private var bridgeAfterDismiss: StoryChapter?
    @State private var searchText = ""

    private var filteredChapters: [StoryChapter] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return store.sortedChapters }
        return store.sortedChapters.filter {
            $0.title.localizedCaseInsensitiveContains(q)
                || $0.chapterDescription.localizedCaseInsensitiveContains(q)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                searchField

                if filteredChapters.isEmpty {
                    EmptyStateView(
                        imageName: "chaptersArt",
                        title: store.chapters.isEmpty ? "No Chapters Yet" : "No Matches",
                        message: store.chapters.isEmpty
                            ? "Create visual chapters to organize your media story."
                            : "Try a different search."
                    )
                    .frame(maxWidth: .infinity)
                } else {
                    LazyVStack(spacing: 14) {
                        ForEach(filteredChapters) { chapter in
                            chapterRow(chapter)
                                .contextMenu {
                                    Button(chapter.isPinned ? "Unpin" : "Pin") {
                                        store.toggleChapterPin(id: chapter.id)
                                    }
                                    Button("Edit") {
                                        editingChapter = chapter
                                        showEditor = true
                                    }
                                    Button("Delete", role: .destructive) {
                                        store.deleteChapter(id: chapter.id)
                                    }
                                }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 28)
        }
        .overlay(alignment: .bottomTrailing) {
            addButton
                .padding(20)
        }
        .sheet(isPresented: $showEditor, onDismiss: {
            if let chapter = bridgeAfterDismiss {
                store.offerJournalBridge(for: chapter)
                bridgeAfterDismiss = nil
            }
        }) {
            ChapterEditorSheet(
                chapter: editingChapter,
                onSave: { chapter in
                    if store.chapters.contains(where: { $0.id == chapter.id }) {
                        store.updateChapter(chapter)
                    } else {
                        store.addChapter(chapter)
                        bridgeAfterDismiss = chapter
                    }
                    editingChapter = nil
                    showEditor = false
                },
                onCancel: {
                    editingChapter = nil
                    bridgeAfterDismiss = nil
                    showEditor = false
                }
            )
        }
        .sheet(isPresented: $showTimeline) {
            TimelineView()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text("Story Chapters")
                    .font(.system(.largeTitle, design: .serif).weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
                Spacer()
                Button {
                    showTimeline = true
                    HapticFeedback.lightTap()
                } label: {
                    Label("Timeline", systemImage: "list.bullet.rectangle")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color("AppTextPrimary"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(theme.primary.opacity(0.35))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            Text("Curate chapters with icons and descriptive context.")
                .font(.subheadline)
                .foregroundStyle(Color("AppTextSecondary"))
            Image("openBookArt")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 120)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    LinearGradient(
                        colors: [.clear, Color("AppBackground").opacity(0.65)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                )
        }
    }

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color("AppTextSecondary"))
            TextField(
                "",
                text: $searchText,
                prompt: Text("Search chapters").foregroundColor(Color("AppTextSecondary"))
            )
            .foregroundStyle(Color("AppTextPrimary"))
            .tint(theme.accent)
        }
        .padding(12)
        .background(Color("AppSurface").opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func chapterRow(_ chapter: StoryChapter) -> some View {
        EditorialCard {
            VStack(alignment: .leading, spacing: 10) {
                if let image = PhotoStorage.load(chapter.imageFileName) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 120)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                HStack(alignment: .top, spacing: 14) {
                    ChapterIconView(icon: chapter.icon, size: 32)
                        .padding(8)
                        .background(Color("AppBackground").opacity(0.45))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(chapter.title)
                                .font(.system(.title3, design: .serif).weight(.semibold))
                                .foregroundStyle(Color("AppTextPrimary"))
                            if chapter.isPinned {
                                Image(systemName: "pin.fill")
                                    .font(.caption)
                                    .foregroundStyle(theme.accent)
                            }
                        }
                        Text(chapter.chapterDescription)
                            .font(.subheadline)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .lineLimit(3)
                        Text(chapter.createdAt.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption2)
                            .foregroundStyle(theme.accent)
                    }
                    Spacer(minLength: 0)
                    Menu {
                        Button(chapter.isPinned ? "Unpin" : "Pin") {
                            store.toggleChapterPin(id: chapter.id)
                        }
                        Button("Edit") {
                            editingChapter = chapter
                            showEditor = true
                        }
                        Button("Delete", role: .destructive) {
                            store.deleteChapter(id: chapter.id)
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title3)
                            .foregroundStyle(theme.accent)
                    }
                }
            }
        }
    }

    private var addButton: some View {
        Button {
            editingChapter = nil
            showEditor = true
            HapticFeedback.lightTap()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "book.closed.fill")
                    .font(.body.weight(.bold))
                Text("New Chapter")
                    .font(.system(.subheadline, design: .serif).weight(.semibold))
            }
            .foregroundStyle(Color("AppTextPrimary"))
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                Capsule()
                    .fill(theme.primary)
                    .shadow(color: theme.primary.opacity(0.45), radius: 10, y: 5)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add Chapter")
    }
}
