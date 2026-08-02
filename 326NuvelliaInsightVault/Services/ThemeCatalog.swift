import Foundation

enum ThemeCatalog {
    static let collections: [ThemeCollection] = [
        ThemeCollection(
            id: "vintage_film",
            title: "Vintage Film",
            subtitle: "Grain, sepia, and reel-to-reel warmth",
            icon: "🎞️",
            tags: ["Sepia", "35mm", "Retro"],
            primaryHex: "C47A3A",
            accentHex: "E8B86D"
        ),
        ThemeCollection(
            id: "neon_nights",
            title: "Neon Nights",
            subtitle: "Electric cityscapes after dark",
            icon: "🌃",
            tags: ["Neon", "Urban", "Night"],
            primaryHex: "FF0090",
            accentHex: "33E1FF"
        ),
        ThemeCollection(
            id: "coastal_diary",
            title: "Coastal Diary",
            subtitle: "Salt air, horizons, and tide lines",
            icon: "🌊",
            tags: ["Ocean", "Travel", "Calm"],
            primaryHex: "1F6F8B",
            accentHex: "99E2D0"
        ),
        ThemeCollection(
            id: "editorial_bloom",
            title: "Editorial Bloom",
            subtitle: "Botanical spreads and serif headlines",
            icon: "🌸",
            tags: ["Floral", "Magazine", "Soft"],
            primaryHex: "D46A8C",
            accentHex: "F3C4D4"
        ),
        ThemeCollection(
            id: "noir_frames",
            title: "Noir Frames",
            subtitle: "High contrast drama and shadow play",
            icon: "🖤",
            tags: ["Monochrome", "Cinema", "Moody"],
            primaryHex: "8E8E93",
            accentHex: "F2F2F7"
        ),
        ThemeCollection(
            id: "golden_hour",
            title: "Golden Hour",
            subtitle: "Sun-washed palettes and long shadows",
            icon: "☀️",
            tags: ["Warm", "Outdoor", "Glow"],
            primaryHex: "E89A2C",
            accentHex: "FFD27A"
        ),
        ThemeCollection(
            id: "minimal_ledger",
            title: "Minimal Ledger",
            subtitle: "Clean grids and quiet captions",
            icon: "📐",
            tags: ["Minimal", "Grid", "Notes"],
            primaryHex: "5B6C7A",
            accentHex: "B8C4CE"
        ),
        ThemeCollection(
            id: "storybook_ink",
            title: "Storybook Ink",
            subtitle: "Illustrated margins and hand-lettered titles",
            icon: "✒️",
            tags: ["Ink", "Illustration", "Classic"],
            primaryHex: "6B3FA0",
            accentHex: "C9A6FF"
        ),
        ThemeCollection(
            id: "festival_pulse",
            title: "Festival Pulse",
            subtitle: "Color bursts and candid motion",
            icon: "🎪",
            tags: ["Live", "Color", "Energy"],
            primaryHex: "FF2D55",
            accentHex: "FFCC00"
        ),
        ThemeCollection(
            id: "winter_atlas",
            title: "Winter Atlas",
            subtitle: "Frost, maps, and quiet interiors",
            icon: "❄️",
            tags: ["Cold", "Map", "Cozy"],
            primaryHex: "4A6FA5",
            accentHex: "A8D0FF"
        )
    ]

    static func collection(id: String?) -> ThemeCollection? {
        guard let id else { return nil }
        return collections.first { $0.id == id }
    }
}
