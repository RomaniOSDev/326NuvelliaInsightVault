import SwiftUI

enum MainTab: String, CaseIterable, Identifiable {
    case chapters
    case journalThemes
    case statistics
    case achievements
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .chapters: return "Chapters"
        case .journalThemes: return "Journal & Themes"
        case .statistics: return "Stats"
        case .achievements: return "Achievements"
        case .settings: return "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .chapters: return "book.pages.fill"
        case .journalThemes: return "text.alignleft"
        case .statistics: return "chart.xyaxis.line"
        case .achievements: return "rosette"
        case .settings: return "gearshape.fill"
        }
    }
}

enum JournalThemesSegment: String, CaseIterable, Identifiable {
    case journal
    case themes

    var id: String { rawValue }

    var title: String {
        switch self {
        case .journal: return "Journal"
        case .themes: return "Themes"
        }
    }
}
