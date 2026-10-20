import Foundation

public struct ToeicScore: Identifiable, Codable, Equatable, Hashable {
    public let id: String
    public let date: Date
    public var listeningScore: Int
    public var readingScore: Int
    public var speakingScore: Int?
    public var writingScore: Int?

    public init(
        id: String = UUID().uuidString,
        date: Date = Date(),
        listeningScore: Int,
        readingScore: Int,
        speakingScore: Int? = nil,
        writingScore: Int? = nil
    ) {
        self.id = id
        self.date = date
        self.listeningScore = listeningScore
        self.readingScore = readingScore
        self.speakingScore = speakingScore
        self.writingScore = writingScore
    }

    public var listening: Int { listeningScore }
    public var reading: Int { readingScore }
    public var speaking: Int { speakingScore ?? 0 }
    public var writing: Int { writingScore ?? 0 }

    public func calculateTotal(isFourSkills: Bool) -> Int {
        if isFourSkills {
            return listeningScore + readingScore + (speakingScore ?? 0) + (writingScore ?? 0)
        }
        return listeningScore + readingScore
    }

    public var total2Skills: Int {
        listeningScore + readingScore
    }

    public var total4Skills: Int {
        listeningScore + readingScore + (speakingScore ?? 0) + (writingScore ?? 0)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case date
        case listeningScore
        case readingScore
        case speakingScore
        case writingScore
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        
        if let dateString = try? container.decode(String.self, forKey: .date) {
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let parsedDate = isoFormatter.date(from: dateString) {
                self.date = parsedDate
            } else {
                let fallback = ISO8601DateFormatter()
                self.date = fallback.date(from: dateString) ?? Date()
            }
        } else if let dateVal = try? container.decode(Date.self, forKey: .date) {
            self.date = dateVal
        } else {
            self.date = Date()
        }

        self.listeningScore = try container.decodeIfPresent(Int.self, forKey: .listeningScore) ?? 0
        self.readingScore = try container.decodeIfPresent(Int.self, forKey: .readingScore) ?? 0
        self.speakingScore = try container.decodeIfPresent(Int.self, forKey: .speakingScore)
        self.writingScore = try container.decodeIfPresent(Int.self, forKey: .writingScore)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        try container.encode(isoFormatter.string(from: date), forKey: .date)
        try container.encode(listeningScore, forKey: .listeningScore)
        try container.encode(readingScore, forKey: .readingScore)
        try container.encodeIfPresent(speakingScore, forKey: .speakingScore)
        try container.encodeIfPresent(writingScore, forKey: .writingScore)
    }
}
