import SwiftUI

struct JournalView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.vaultTheme) private var theme
    @State private var showEditor = false
    @State private var showQuickCapture = false
    @State private var editingEntry: JournalEntry?
    @State private var searchText = ""
    @State private var selectedMood: MoodTag?
    @State private var filterChapterId: UUID?
    @State private var dateFrom: Date?
    @State private var showDateFilter = false
    @State private var didLongPressWrite = false

    private var filteredEntries: [JournalEntry] {
        store.journalEntries.filter { entry in
            let matchesSearch: Bool = {
                let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !q.isEmpty else { return true }
                let chapterTitle = store.chapterTitle(for: entry.chapterId) ?? ""
                return entry.caption.localizedCaseInsensitiveContains(q)
                    || chapterTitle.localizedCaseInsensitiveContains(q)
                    || (entry.moodTag?.title.localizedCaseInsensitiveContains(q) ?? false)
            }()
            let matchesMood = selectedMood == nil || entry.moodTag == selectedMood
            let matchesChapter = filterChapterId == nil || entry.chapterId == filterChapterId
            let matchesDate: Bool = {
                guard let dateFrom else { return true }
                return entry.date >= Calendar.current.startOfDay(for: dateFrom)
            }()
            return matchesSearch && matchesMood && matchesChapter && matchesDate
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .firstTextBaseline) {
                    Text("Journal Narratives")
                        .font(.system(.largeTitle, design: .serif).weight(.bold))
                        .foregroundStyle(Color("AppTextPrimary"))
                    Spacer()
                    if store.currentStreak > 0 {
                        Label("\(store.currentStreak)", systemImage: "flame.fill")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(theme.accent)
                    }
                }

                searchField
                filterRow

                Image("bannerJournals")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 110)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(theme.primary.opacity(0.4), lineWidth: 1)
                    )

                if filteredEntries.isEmpty {
                    EmptyStateView(
                        imageName: "bannerJournals",
                        title: store.journalEntries.isEmpty ? "No Narratives Yet" : "No Matches",
                        message: store.journalEntries.isEmpty
                            ? "Capture captions and dates, optionally linked to a chapter."
                            : "Try a different search or filter."
                    )
                    .frame(maxWidth: .infinity)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredEntries) { entry in
                            journalRow(entry)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 88)
        }
        .overlay(alignment: .bottomLeading) {
            writeButton
                .padding(20)
        }
        .sheet(isPresented: $showEditor) {
            JournalEditorSheet(
                entry: editingEntry,
                onSave: { entry in
                    if store.journalEntries.contains(where: { $0.id == entry.id }) {
                        store.updateJournalEntry(entry)
                    } else {
                        store.addJournalEntry(entry)
                    }
                    editingEntry = nil
                    showEditor = false
                },
                onCancel: {
                    editingEntry = nil
                    showEditor = false
                }
            )
        }
        .sheet(isPresented: $showQuickCapture) {
            QuickCaptureSheet()
        }
    }

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color("AppTextSecondary"))
            TextField(
                "",
                text: $searchText,
                prompt: Text("Search narratives").foregroundColor(Color("AppTextSecondary"))
            )
            .foregroundStyle(Color("AppTextPrimary"))
            .tint(theme.accent)
        }
        .padding(12)
        .background(Color("AppSurface").opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var filterRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    filterChip(title: "All moods", selected: selectedMood == nil) {
                        selectedMood = nil
                    }
                    ForEach(MoodTag.allCases) { tag in
                        filterChip(title: tag.title, selected: selectedMood == tag) {
                            selectedMood = tag
                        }
                    }
                }
            }

            HStack(spacing: 8) {
                Menu {
                    Button("All chapters") { filterChapterId = nil }
                    ForEach(store.sortedChapters) { chapter in
                        Button(chapter.title) { filterChapterId = chapter.id }
                    }
                } label: {
                    Label(
                        filterChapterId.flatMap { store.chapterTitle(for: $0) } ?? "Chapter",
                        systemImage: "line.3.horizontal.decrease.circle"
                    )
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Color("AppSurface"))
                    .clipShape(Capsule())
                }

                Button {
                    showDateFilter.toggle()
                    if !showDateFilter { dateFrom = nil }
                } label: {
                    Label(dateFrom == nil ? "From date" : "Clear date", systemImage: "calendar")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color("AppTextPrimary"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(dateFrom == nil ? Color("AppSurface") : theme.primary.opacity(0.35))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }

            if showDateFilter {
                DatePicker(
                    "From",
                    selection: Binding(
                        get: { dateFrom ?? Date() },
                        set: { dateFrom = $0 }
                    ),
                    displayedComponents: .date
                )
                .tint(theme.primary)
                .colorScheme(.dark)
            }
        }
    }

    private func filterChip(title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            HapticFeedback.selection()
            action()
        } label: {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color("AppTextPrimary"))
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(selected ? theme.primary.opacity(0.45) : Color("AppSurface"))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private var writeButton: some View {
        Button {
            if didLongPressWrite {
                didLongPressWrite = false
                return
            }
            editingEntry = nil
            showEditor = true
            HapticFeedback.lightTap()
        } label: {
            Label("Write Entry", systemImage: "pencil.line")
                .font(.system(.subheadline, design: .serif).weight(.semibold))
                .foregroundStyle(Color("AppTextPrimary"))
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(theme.primary, lineWidth: 1.5)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color("AppSurface").opacity(0.92))
                        )
                )
                .shadow(color: Color.black.opacity(0.25), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.45).onEnded { _ in
                didLongPressWrite = true
                HapticFeedback.success()
                showQuickCapture = true
            }
        )
        .accessibilityHint("Long press for quick capture")
    }

    private func journalRow(_ entry: JournalEntry) -> some View {
        EditorialCard {
            VStack(alignment: .leading, spacing: 8) {
                if let image = PhotoStorage.load(entry.imageFileName) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 120)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                Text(entry.caption)
                    .font(.body)
                    .foregroundStyle(Color("AppTextPrimary"))
                HStack {
                    Text(entry.date.formatted(date: .long, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(theme.accent)
                    Spacer()
                    if let mood = entry.moodTag {
                        Label(mood.title, systemImage: mood.symbol)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
                if let chapterTitle = store.chapterTitle(for: entry.chapterId) {
                    Label(chapterTitle, systemImage: "link")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(1)
                }
                HStack {
                    Spacer()
                    Button("Edit") {
                        editingEntry = entry
                        showEditor = true
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(theme.accent)
                    Button("Delete", role: .destructive) {
                        store.deleteJournalEntry(id: entry.id)
                    }
                    .font(.caption.weight(.semibold))
                }
            }
        }
    }
}
