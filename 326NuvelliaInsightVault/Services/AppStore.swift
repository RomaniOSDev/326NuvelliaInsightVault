import Combine
import Foundation
import SwiftUI
import UIKit

final class AppStore: ObservableObject {
    @Published private(set) var chapters: [StoryChapter] = []
    @Published private(set) var journalEntries: [JournalEntry] = []
    @Published private(set) var favoriteThemeIds: Set<String> = []
    @Published private(set) var hasCompletedOnboarding = false
    @Published var soundEnabled = true
    @Published var hapticsEnabled = true
    @Published var remindersEnabled = false
    @Published var appliedThemeId: String?

    @Published var pendingChapterForJournal: StoryChapter?

    private let defaults: UserDefaults

    enum Keys {
        static let chapters = "vault.chapters"
        static let journal = "vault.journal"
        static let favorites = "vault.favoriteThemes"
        static let onboarding = "vault.onboardingDone"
        static let soundEnabled = "vault.soundEnabled"
        static let hapticsEnabled = "vault.hapticsEnabled"
        static let remindersEnabled = "vault.remindersEnabled"
        static let appliedThemeId = "vault.appliedThemeId"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
    }

    var itemsAdded: Int { chapters.count }
    var entriesWritten: Int { journalEntries.count }
    var favouritesCount: Int { favoriteThemeIds.count }

    var sortedChapters: [StoryChapter] {
        chapters.sorted { lhs, rhs in
            if lhs.isPinned != rhs.isPinned { return lhs.isPinned && !rhs.isPinned }
            return lhs.createdAt > rhs.createdAt
        }
    }

    var vaultTheme: VaultTheme {
        guard let theme = ThemeCatalog.collection(id: appliedThemeId) else {
            return .standard
        }
        return VaultTheme(
            primary: Color(hex: theme.primaryHex),
            accent: Color(hex: theme.accentHex)
        )
    }

    var currentStreak: Int {
        streak(endingOn: Date())
    }

    var weekNarrativeCount: Int {
        let calendar = Calendar.current
        guard let start = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) else {
            return 0
        }
        return journalEntries.filter { $0.date >= start }.count
    }

    var weekChapterCount: Int {
        let calendar = Calendar.current
        guard let start = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) else {
            return 0
        }
        return chapters.filter { $0.createdAt >= start }.count
    }

    var topMoodThisWeek: MoodTag? {
        let calendar = Calendar.current
        guard let start = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) else {
            return nil
        }
        var counts: [MoodTag: Int] = [:]
        for entry in journalEntries where entry.date >= start {
            if let mood = entry.moodTag {
                counts[mood, default: 0] += 1
            }
        }
        return counts.max(by: { $0.value < $1.value })?.key
    }

    var snapshot: AppStoreSnapshot {
        AppStoreSnapshot(
            itemsAdded: itemsAdded,
            entriesWritten: entriesWritten,
            favouritesCount: favouritesCount,
            currentStreak: currentStreak
        )
    }

    func setSoundEnabled(_ enabled: Bool) {
        soundEnabled = enabled
        defaults.set(enabled, forKey: Keys.soundEnabled)
        if enabled { HapticFeedback.selection() }
    }

    func setHapticsEnabled(_ enabled: Bool) {
        hapticsEnabled = enabled
        defaults.set(enabled, forKey: Keys.hapticsEnabled)
        if enabled { HapticFeedback.selection() }
    }

    func setRemindersEnabled(_ enabled: Bool) {
        if enabled {
            ReminderScheduler.requestAuthorization { granted in
                self.remindersEnabled = granted
                self.defaults.set(granted, forKey: Keys.remindersEnabled)
                if granted {
                    ReminderScheduler.scheduleDailyReminder()
                    HapticFeedback.success()
                } else {
                    ReminderScheduler.cancel()
                }
            }
        } else {
            remindersEnabled = false
            defaults.set(false, forKey: Keys.remindersEnabled)
            ReminderScheduler.cancel()
            HapticFeedback.lightTap()
        }
    }

    func applyTheme(id: String?) {
        appliedThemeId = id
        if let id {
            defaults.set(id, forKey: Keys.appliedThemeId)
        } else {
            defaults.removeObject(forKey: Keys.appliedThemeId)
        }
        HapticFeedback.success()
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        defaults.set(true, forKey: Keys.onboarding)
        HapticFeedback.success()
    }

    func addChapter(_ chapter: StoryChapter) {
        chapters.insert(chapter, at: 0)
        persistChapters()
        HapticFeedback.success()
    }

    func offerJournalBridge(for chapter: StoryChapter) {
        pendingChapterForJournal = chapter
    }

    func updateChapter(_ chapter: StoryChapter) {
        guard let index = chapters.firstIndex(where: { $0.id == chapter.id }) else { return }
        let previous = chapters[index]
        if previous.imageFileName != chapter.imageFileName {
            PhotoStorage.delete(previous.imageFileName)
        }
        chapters[index] = chapter
        persistChapters()
        HapticFeedback.lightTap()
    }

    func toggleChapterPin(id: UUID) {
        guard let index = chapters.firstIndex(where: { $0.id == id }) else { return }
        chapters[index].isPinned.toggle()
        persistChapters()
        HapticFeedback.selection()
    }

    func deleteChapter(at offsets: IndexSet) {
        let removed = offsets.map { chapters[$0] }
        deleteChapters(removed)
    }

    func deleteChapter(id: UUID) {
        let removed = chapters.filter { $0.id == id }
        deleteChapters(removed)
    }

    func clearPendingChapterBridge() {
        pendingChapterForJournal = nil
    }

    func addJournalEntry(_ entry: JournalEntry) {
        journalEntries.insert(entry, at: 0)
        persistJournal()
        HapticFeedback.success()
    }

    func updateJournalEntry(_ entry: JournalEntry) {
        guard let index = journalEntries.firstIndex(where: { $0.id == entry.id }) else { return }
        let previous = journalEntries[index]
        if previous.imageFileName != entry.imageFileName {
            PhotoStorage.delete(previous.imageFileName)
        }
        journalEntries[index] = entry
        persistJournal()
        HapticFeedback.lightTap()
    }

    func deleteJournalEntry(at offsets: IndexSet) {
        let removed = offsets.map { journalEntries[$0] }
        deleteJournalEntries(removed)
    }

    func deleteJournalEntry(id: UUID) {
        let removed = journalEntries.filter { $0.id == id }
        deleteJournalEntries(removed)
    }

    func chapterTitle(for id: UUID?) -> String? {
        guard let id else { return nil }
        return chapters.first(where: { $0.id == id })?.title
    }

    func isThemeFavorite(_ themeId: String) -> Bool {
        favoriteThemeIds.contains(themeId)
    }

    func toggleThemeFavorite(_ themeId: String) {
        if favoriteThemeIds.contains(themeId) {
            favoriteThemeIds.remove(themeId)
            if appliedThemeId == themeId {
                applyTheme(id: nil)
            }
        } else {
            favoriteThemeIds.insert(themeId)
        }
        persistFavorites()
        HapticFeedback.selection()
    }

    func saveImage(_ image: UIImage) -> String? {
        PhotoStorage.save(image)
    }

    func resetAllData() {
        for chapter in chapters {
            PhotoStorage.delete(chapter.imageFileName)
        }
        for entry in journalEntries {
            PhotoStorage.delete(entry.imageFileName)
        }
        chapters = []
        journalEntries = []
        favoriteThemeIds = []
        hasCompletedOnboarding = false
        pendingChapterForJournal = nil
        appliedThemeId = nil
        remindersEnabled = false
        ReminderScheduler.cancel()
        defaults.removeObject(forKey: Keys.chapters)
        defaults.removeObject(forKey: Keys.journal)
        defaults.removeObject(forKey: Keys.favorites)
        defaults.removeObject(forKey: Keys.onboarding)
        defaults.removeObject(forKey: Keys.appliedThemeId)
        defaults.removeObject(forKey: Keys.remindersEnabled)
        NotificationCenter.default.post(name: .dataReset, object: nil)
        HapticFeedback.warning()
    }

    private func deleteChapters(_ removed: [StoryChapter]) {
        let removedIds = Set(removed.map(\.id))
        for chapter in removed {
            PhotoStorage.delete(chapter.imageFileName)
        }
        chapters.removeAll { removedIds.contains($0.id) }
        journalEntries = journalEntries.map { entry in
            var copy = entry
            if let chapterId = copy.chapterId, removedIds.contains(chapterId) {
                copy.chapterId = nil
            }
            return copy
        }
        persistChapters()
        persistJournal()
        HapticFeedback.warning()
    }

    private func deleteJournalEntries(_ removed: [JournalEntry]) {
        let removedIds = Set(removed.map(\.id))
        for entry in removed {
            PhotoStorage.delete(entry.imageFileName)
        }
        journalEntries.removeAll { removedIds.contains($0.id) }
        persistJournal()
        HapticFeedback.warning()
    }

    private func streak(endingOn date: Date) -> Int {
        let calendar = Calendar.current
        let daysWithEntries = Set(
            journalEntries.map { calendar.startOfDay(for: $0.date) }
        )
        guard !daysWithEntries.isEmpty else { return 0 }

        var cursor = calendar.startOfDay(for: date)
        if !daysWithEntries.contains(cursor) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: cursor) else { return 0 }
            cursor = yesterday
            if !daysWithEntries.contains(cursor) { return 0 }
        }

        var count = 0
        while daysWithEntries.contains(cursor) {
            count += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previous
        }
        return count
    }

    private func load() {
        hasCompletedOnboarding = defaults.bool(forKey: Keys.onboarding)
        if defaults.object(forKey: Keys.soundEnabled) == nil {
            soundEnabled = true
        } else {
            soundEnabled = defaults.bool(forKey: Keys.soundEnabled)
        }
        if defaults.object(forKey: Keys.hapticsEnabled) == nil {
            hapticsEnabled = true
        } else {
            hapticsEnabled = defaults.bool(forKey: Keys.hapticsEnabled)
        }
        remindersEnabled = defaults.bool(forKey: Keys.remindersEnabled)
        appliedThemeId = defaults.string(forKey: Keys.appliedThemeId)
        if remindersEnabled {
            ReminderScheduler.scheduleDailyReminder()
        }
        if let data = defaults.data(forKey: Keys.chapters),
           let decoded = try? JSONDecoder().decode([StoryChapter].self, from: data) {
            chapters = decoded
        }
        if let data = defaults.data(forKey: Keys.journal),
           let decoded = try? JSONDecoder().decode([JournalEntry].self, from: data) {
            journalEntries = decoded
        }
        if let ids = defaults.stringArray(forKey: Keys.favorites) {
            favoriteThemeIds = Set(ids)
        }
    }

    private func persistChapters() {
        if let data = try? JSONEncoder().encode(chapters) {
            defaults.set(data, forKey: Keys.chapters)
        }
    }

    private func persistJournal() {
        if let data = try? JSONEncoder().encode(journalEntries) {
            defaults.set(data, forKey: Keys.journal)
        }
    }

    private func persistFavorites() {
        defaults.set(Array(favoriteThemeIds), forKey: Keys.favorites)
    }
}
