import Charts
import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.vaultTheme) private var theme
    @State private var showWeeklyReview = false

    private var activityPoints: [DailyActivityPoint] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let start = calendar.date(byAdding: .day, value: -13, to: today) else { return [] }

        var chapterCounts: [Date: Int] = [:]
        var journalCounts: [Date: Int] = [:]

        for chapter in store.chapters {
            let day = calendar.startOfDay(for: chapter.createdAt)
            guard day >= start else { continue }
            chapterCounts[day, default: 0] += 1
        }
        for entry in store.journalEntries {
            let day = calendar.startOfDay(for: entry.date)
            guard day >= start else { continue }
            journalCounts[day, default: 0] += 1
        }

        return (0..<14).compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: offset, to: start) else { return nil }
            return DailyActivityPoint(
                date: day,
                chapters: chapterCounts[day, default: 0],
                narratives: journalCounts[day, default: 0]
            )
        }
    }

    private var chapterBreakdown: [ChapterLinkPoint] {
        store.chapters.map { chapter in
            ChapterLinkPoint(
                title: chapter.title,
                count: store.journalEntries.filter { $0.chapterId == chapter.id }.count
            )
        }
        .sorted { $0.count > $1.count }
        .prefix(6)
        .map { $0 }
    }

    private var linkedCount: Int {
        store.journalEntries.filter { $0.chapterId != nil }.count
    }

    private var unlinkedCount: Int {
        store.journalEntries.count - linkedCount
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .firstTextBaseline) {
                    Text("Statistics")
                        .font(.system(.largeTitle, design: .serif).weight(.bold))
                        .foregroundStyle(Color("AppTextPrimary"))
                    Spacer()
                    Button {
                        showWeeklyReview = true
                        HapticFeedback.lightTap()
                    } label: {
                        Label("Weekly", systemImage: "calendar.badge.clock")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color("AppTextPrimary"))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(theme.primary.opacity(0.35))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }

                Text("See how your story grows over time.")
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))

                summaryGrid

                EditorialCard {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Activity · 14 days")
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))

                        if activityPoints.allSatisfy({ $0.chapters == 0 && $0.narratives == 0 }) {
                            Text("Create chapters or narratives to populate this chart.")
                                .font(.caption)
                                .foregroundStyle(Color("AppTextSecondary"))
                                .frame(maxWidth: .infinity, minHeight: 160, alignment: .center)
                        } else {
                            Chart {
                                ForEach(activityPoints) { point in
                                    BarMark(
                                        x: .value("Day", point.date, unit: .day),
                                        y: .value("Count", point.chapters)
                                    )
                                    .foregroundStyle(theme.primary)
                                    .position(by: .value("Kind", "Chapters"))

                                    BarMark(
                                        x: .value("Day", point.date, unit: .day),
                                        y: .value("Count", point.narratives)
                                    )
                                    .foregroundStyle(theme.accent)
                                    .position(by: .value("Kind", "Narratives"))
                                }
                            }
                            .chartXAxis {
                                AxisMarks(values: .stride(by: .day, count: 3)) { value in
                                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                        .foregroundStyle(Color("AppTextSecondary").opacity(0.25))
                                    AxisValueLabel {
                                        if let date = value.as(Date.self) {
                                            Text(date, format: .dateTime.month(.abbreviated).day())
                                                .font(.caption2)
                                                .foregroundStyle(Color("AppTextSecondary"))
                                        }
                                    }
                                }
                            }
                            .chartYAxis {
                                AxisMarks(position: .leading) { value in
                                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                        .foregroundStyle(Color("AppTextSecondary").opacity(0.25))
                                    AxisValueLabel {
                                        if let intValue = value.as(Int.self) {
                                            Text("\(intValue)")
                                                .font(.caption2)
                                                .foregroundStyle(Color("AppTextSecondary"))
                                        }
                                    }
                                }
                            }
                            .frame(height: 200)

                            HStack(spacing: 16) {
                                legendDot(color: theme.primary, title: "Chapters")
                                legendDot(color: theme.accent, title: "Narratives")
                            }
                        }
                    }
                }

                EditorialCard {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Narratives by chapter")
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))

                        if chapterBreakdown.isEmpty {
                            Text("Link journal entries to chapters to see this breakdown.")
                                .font(.caption)
                                .foregroundStyle(Color("AppTextSecondary"))
                                .frame(maxWidth: .infinity, minHeight: 140, alignment: .center)
                        } else {
                            Chart(chapterBreakdown) { point in
                                BarMark(
                                    x: .value("Count", point.count),
                                    y: .value("Chapter", point.title)
                                )
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [theme.primary, theme.accent],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            }
                            .chartXAxis {
                                AxisMarks { value in
                                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                        .foregroundStyle(Color("AppTextSecondary").opacity(0.25))
                                    AxisValueLabel {
                                        if let intValue = value.as(Int.self) {
                                            Text("\(intValue)")
                                                .font(.caption2)
                                                .foregroundStyle(Color("AppTextSecondary"))
                                        }
                                    }
                                }
                            }
                            .chartYAxis {
                                AxisMarks { value in
                                    AxisValueLabel {
                                        if let title = value.as(String.self) {
                                            Text(title)
                                                .font(.caption2)
                                                .foregroundStyle(Color("AppTextPrimary"))
                                                .lineLimit(1)
                                        }
                                    }
                                }
                            }
                            .frame(height: CGFloat(max(140, chapterBreakdown.count * 36)))
                        }
                    }
                }

                EditorialCard {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Link coverage")
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))

                        if store.journalEntries.isEmpty {
                            Text("No narratives yet.")
                                .font(.caption)
                                .foregroundStyle(Color("AppTextSecondary"))
                                .frame(maxWidth: .infinity, minHeight: 140, alignment: .center)
                        } else {
                            Chart {
                                BarMark(
                                    x: .value("Count", linkedCount),
                                    y: .value("Type", "Linked")
                                )
                                .foregroundStyle(theme.accent)
                                BarMark(
                                    x: .value("Count", unlinkedCount),
                                    y: .value("Type", "Standalone")
                                )
                                .foregroundStyle(theme.primary.opacity(0.75))
                            }
                            .chartXAxis {
                                AxisMarks { value in
                                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                        .foregroundStyle(Color("AppTextSecondary").opacity(0.25))
                                    AxisValueLabel {
                                        if let intValue = value.as(Int.self) {
                                            Text("\(intValue)")
                                                .font(.caption2)
                                                .foregroundStyle(Color("AppTextSecondary"))
                                        }
                                    }
                                }
                            }
                            .chartYAxis {
                                AxisMarks { value in
                                    AxisValueLabel {
                                        if let title = value.as(String.self) {
                                            Text(title)
                                                .font(.caption2)
                                                .foregroundStyle(Color("AppTextPrimary"))
                                        }
                                    }
                                }
                            }
                            .frame(height: 120)

                            HStack(spacing: 16) {
                                legendDot(color: theme.accent, title: "Linked · \(linkedCount)")
                                legendDot(color: theme.primary.opacity(0.75), title: "Standalone · \(unlinkedCount)")
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 28)
        }
        .sheet(isPresented: $showWeeklyReview) {
            WeeklyReviewView()
        }
    }

    private var summaryGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            summaryTile(title: "Chapters", value: "\(store.itemsAdded)", icon: "book.pages.fill")
            summaryTile(title: "Narratives", value: "\(store.entriesWritten)", icon: "text.alignleft")
            summaryTile(title: "Streak", value: "\(store.currentStreak)d", icon: "flame.fill")
            summaryTile(
                title: "Linked",
                value: store.entriesWritten == 0
                    ? "0%"
                    : "\(Int((Double(linkedCount) / Double(store.entriesWritten)) * 100))%",
                icon: "link"
            )
        }
    }

    private func summaryTile(title: String, value: String, icon: String) -> some View {
        EditorialCard {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(theme.accent)
                Text(value)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
                Text(title)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
        }
    }

    private func legendDot(color: Color, title: String) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(title)
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
        }
    }
}

private struct DailyActivityPoint: Identifiable {
    let date: Date
    let chapters: Int
    let narratives: Int
    var id: Date { date }
}

private struct ChapterLinkPoint: Identifiable {
    let title: String
    let count: Int
    var id: String { title }
}
