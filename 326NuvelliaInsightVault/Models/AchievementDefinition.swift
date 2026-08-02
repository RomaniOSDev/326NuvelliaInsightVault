import Foundation

struct AchievementDefinition: Identifiable {
    let id: String
    let title: String
    let detail: String
    let systemImage: String
    let isUnlocked: (AppStoreSnapshot) -> Bool

    static func all() -> [AchievementDefinition] {
        [
            AchievementDefinition(
                id: "first_chapter",
                title: "First Chapter",
                detail: "Create your first visual chapter",
                systemImage: "book.closed.fill",
                isUnlocked: { $0.itemsAdded >= 1 }
            ),
            AchievementDefinition(
                id: "narrative_starter",
                title: "Narrative Starter",
                detail: "Write your first journal narrative",
                systemImage: "pencil.line",
                isUnlocked: { $0.entriesWritten >= 1 }
            ),
            AchievementDefinition(
                id: "chronicler",
                title: "Chronicler",
                detail: "Organize 10 story chapters",
                systemImage: "books.vertical.fill",
                isUnlocked: { $0.itemsAdded >= 10 }
            ),
            AchievementDefinition(
                id: "storyteller",
                title: "Storyteller",
                detail: "Compose 20 journal narratives",
                systemImage: "text.book.closed.fill",
                isUnlocked: { $0.entriesWritten >= 20 }
            ),
            AchievementDefinition(
                id: "favorite_collector",
                title: "Favorite Collector",
                detail: "Favorite 5 theme collections",
                systemImage: "heart.fill",
                isUnlocked: { $0.favouritesCount >= 5 }
            ),
            AchievementDefinition(
                id: "visual_archivist",
                title: "Visual Archivist",
                detail: "Curate 30 story chapters",
                systemImage: "photo.stack.fill",
                isUnlocked: { $0.itemsAdded >= 30 }
            ),
            AchievementDefinition(
                id: "annotation_expert",
                title: "Annotation Expert",
                detail: "Write 50 journal narratives",
                systemImage: "highlighter",
                isUnlocked: { $0.entriesWritten >= 50 }
            ),
            AchievementDefinition(
                id: "chapter_enthusiast",
                title: "Chapter Enthusiast",
                detail: "Favorite 15 theme collections",
                systemImage: "sparkles",
                isUnlocked: { $0.favouritesCount >= 15 }
            ),
            AchievementDefinition(
                id: "streak_spark",
                title: "Streak Spark",
                detail: "Keep a 3-day writing streak",
                systemImage: "flame.fill",
                isUnlocked: { $0.currentStreak >= 3 }
            ),
            AchievementDefinition(
                id: "streak_keeper",
                title: "Streak Keeper",
                detail: "Keep a 7-day writing streak",
                systemImage: "flame.circle.fill",
                isUnlocked: { $0.currentStreak >= 7 }
            )
        ]
    }
}

struct AppStoreSnapshot {
    let itemsAdded: Int
    let entriesWritten: Int
    let favouritesCount: Int
    let currentStreak: Int
}
