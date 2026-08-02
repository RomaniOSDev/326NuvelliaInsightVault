import Charts
import SwiftUI

struct WeeklyReviewView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.vaultTheme) private var theme
    @Environment(\.dismiss) private var dismiss

    private var weekDays: [WeekDayPoint] {
        let calendar = Calendar.current
        guard let start = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) else {
            return []
        }
        return (0..<7).compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: offset, to: start) else { return nil }
            let count = store.journalEntries.filter {
                calendar.isDate($0.date, inSameDayAs: day)
            }.count
            return WeekDayPoint(date: day, count: count)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Weekly Review")
                        .font(.system(.largeTitle, design: .serif).weight(.bold))
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text("A snapshot of this week’s storytelling pace.")
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextSecondary"))

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        metric("Streak", "\(store.currentStreak)d", "flame.fill")
                        metric("Narratives", "\(store.weekNarrativeCount)", "text.alignleft")
                        metric("Chapters", "\(store.weekChapterCount)", "book.pages.fill")
                        metric(
                            "Top mood",
                            store.topMoodThisWeek?.title ?? "—",
                            store.topMoodThisWeek?.symbol ?? "face.smiling"
                        )
                    }

                    EditorialCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Narratives this week")
                                .font(.headline)
                                .foregroundStyle(Color("AppTextPrimary"))
                            Chart(weekDays) { point in
                                LineMark(
                                    x: .value("Day", point.date, unit: .day),
                                    y: .value("Count", point.count)
                                )
                                .foregroundStyle(theme.accent)
                                .interpolationMethod(.catmullRom)
                                AreaMark(
                                    x: .value("Day", point.date, unit: .day),
                                    y: .value("Count", point.count)
                                )
                                .foregroundStyle(theme.primary.opacity(0.25))
                                .interpolationMethod(.catmullRom)
                            }
                            .chartXAxis {
                                AxisMarks(values: .stride(by: .day)) { value in
                                    AxisValueLabel {
                                        if let date = value.as(Date.self) {
                                            Text(date, format: .dateTime.weekday(.narrow))
                                                .font(.caption2)
                                                .foregroundStyle(Color("AppTextSecondary"))
                                        }
                                    }
                                }
                            }
                            .chartYAxis {
                                AxisMarks(position: .leading) { value in
                                    AxisValueLabel {
                                        if let intValue = value.as(Int.self) {
                                            Text("\(intValue)")
                                                .font(.caption2)
                                                .foregroundStyle(Color("AppTextSecondary"))
                                        }
                                    }
                                }
                            }
                            .frame(height: 180)
                        }
                    }

                    if store.currentStreak > 0 {
                        EditorialCard {
                            HStack(spacing: 12) {
                                Image(systemName: "flame.fill")
                                    .font(.title2)
                                    .foregroundStyle(theme.accent)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("You’re on a \(store.currentStreak)-day streak")
                                        .font(.headline)
                                        .foregroundStyle(Color("AppTextPrimary"))
                                    Text("Write once today to keep the flame alive.")
                                        .font(.caption)
                                        .foregroundStyle(Color("AppTextSecondary"))
                                }
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

    private func metric(_ title: String, _ value: String, _ icon: String) -> some View {
        EditorialCard {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(theme.accent)
                Text(value)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
        }
    }
}

private struct WeekDayPoint: Identifiable {
    let date: Date
    let count: Int
    var id: Date { date }
}
