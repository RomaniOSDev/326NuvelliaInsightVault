import SwiftUI

struct TimelineView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.vaultTheme) private var theme
    @Environment(\.dismiss) private var dismiss

    private var events: [TimelineEvent] {
        var items: [TimelineEvent] = []
        for chapter in store.sortedChapters {
            let linked = store.journalEntries
                .filter { $0.chapterId == chapter.id }
                .sorted { $0.date > $1.date }
            items.append(
                TimelineEvent(
                    id: chapter.id,
                    date: chapter.createdAt,
                    title: chapter.title,
                    detail: chapter.chapterDescription,
                    icon: chapter.icon,
                    isPinned: chapter.isPinned,
                    narratives: linked
                )
            )
        }
        return items.sorted { $0.date > $1.date }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Chapter Timeline")
                        .font(.system(.largeTitle, design: .serif).weight(.bold))
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text("Your story in chronological order, with linked narratives.")
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextSecondary"))

                    if events.isEmpty {
                        EmptyStateView(
                            imageName: "chaptersArt",
                            title: "Timeline is empty",
                            message: "Create chapters to build your visual storyline."
                        )
                        .frame(maxWidth: .infinity)
                    } else {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                                timelineRow(event, isLast: index == events.count - 1)
                            }
                        }
                    }
                }
                .padding(20)
            }
            .storybookBackground()
            .vaultNavigationChrome()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
        }
    }

    private func timelineRow(_ event: TimelineEvent, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 0) {
                Circle()
                    .fill(theme.accent)
                    .frame(width: 12, height: 12)
                    .padding(.top, 6)
                if !isLast {
                    Rectangle()
                        .fill(theme.primary.opacity(0.45))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 12)

            EditorialCard {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        ChapterIconView(icon: event.icon, size: 22)
                        Text(event.title)
                            .font(.system(.title3, design: .serif).weight(.semibold))
                            .foregroundStyle(Color("AppTextPrimary"))
                        if event.isPinned {
                            Image(systemName: "pin.fill")
                                .font(.caption)
                                .foregroundStyle(theme.accent)
                        }
                        Spacer()
                        Text(event.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption2)
                            .foregroundStyle(theme.accent)
                    }
                    if !event.detail.isEmpty {
                        Text(event.detail)
                            .font(.subheadline)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                    if event.narratives.isEmpty {
                        Text("No linked narratives")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                    } else {
                        ForEach(event.narratives.prefix(3)) { entry in
                            Text("• \(entry.caption)")
                                .font(.caption)
                                .foregroundStyle(Color("AppTextPrimary"))
                                .lineLimit(2)
                        }
                        if event.narratives.count > 3 {
                            Text("+\(event.narratives.count - 3) more")
                                .font(.caption2)
                                .foregroundStyle(theme.accent)
                        }
                    }
                }
            }
            .padding(.bottom, 16)
        }
    }
}

private struct TimelineEvent: Identifiable {
    let id: UUID
    let date: Date
    let title: String
    let detail: String
    let icon: String
    let isPinned: Bool
    let narratives: [JournalEntry]
}
