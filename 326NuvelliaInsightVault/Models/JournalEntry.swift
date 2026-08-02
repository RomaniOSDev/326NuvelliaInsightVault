import Foundation

struct JournalEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var caption: String
    var date: Date
    var chapterId: UUID?
    var mood: String?
    var imageFileName: String?

    init(
        id: UUID = UUID(),
        caption: String,
        date: Date = Date(),
        chapterId: UUID? = nil,
        mood: String? = nil,
        imageFileName: String? = nil
    ) {
        self.id = id
        self.caption = caption
        self.date = date
        self.chapterId = chapterId
        self.mood = mood
        self.imageFileName = imageFileName
    }

    var moodTag: MoodTag? {
        guard let mood else { return nil }
        return MoodTag(rawValue: mood)
    }

    enum CodingKeys: String, CodingKey {
        case id, caption, date, chapterId, mood, imageFileName
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        caption = try container.decode(String.self, forKey: .caption)
        date = try container.decode(Date.self, forKey: .date)
        chapterId = try container.decodeIfPresent(UUID.self, forKey: .chapterId)
        mood = try container.decodeIfPresent(String.self, forKey: .mood)
        imageFileName = try container.decodeIfPresent(String.self, forKey: .imageFileName)
    }
}
