import Foundation

public struct UserModel: Identifiable, Codable, Equatable, Hashable {
    public let id: String
    public var authUid: String?
    public var name: String
    public var dateOfBirth: Date
    public var targetScore: Int
    public var avatarUrl: String?
    public var isFourSkills: Bool
    public var scores: [ToeicScore]
    public var chatHistory: [MunAIChatSession]
    public var groupId: String?
    public var groupRole: String?
    public var pendingGroupId: String?
    public var isDisabled: Bool
    public var isAdmin: Bool

    public init(
        id: String = UUID().uuidString,
        authUid: String? = nil,
        name: String,
        dateOfBirth: Date = Calendar.current.date(from: DateComponents(year: 2004, month: 1, day: 1)) ?? Date(),
        targetScore: Int = 500,
        avatarUrl: String? = nil,
        isFourSkills: Bool = false,
        scores: [ToeicScore] = [],
        chatHistory: [MunAIChatSession] = [],
        groupId: String? = nil,
        groupRole: String? = nil,
        pendingGroupId: String? = nil,
        isDisabled: Bool = false,
        isAdmin: Bool = false
    ) {
        self.id = id
        self.authUid = authUid
        self.name = name
        self.dateOfBirth = dateOfBirth
        self.targetScore = targetScore
        self.avatarUrl = avatarUrl
        self.isFourSkills = isFourSkills
        self.scores = scores
        self.chatHistory = chatHistory
        self.groupId = groupId
        self.groupRole = groupRole
        self.pendingGroupId = pendingGroupId
        self.isDisabled = isDisabled
        self.isAdmin = isAdmin
    }

    public var currentStreak: Int {
        if scores.isEmpty { return 0 }

        let calendar = Calendar(identifier: .gregorian)
        let uniqueDays: [Date] = Array(Set(scores.map { calendar.startOfDay(for: $0.date) }))
            .sorted(by: { $0 > $1 })

        guard let mostRecent = uniqueDays.first else { return 0 }

        let today = calendar.startOfDay(for: Date())
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else { return 0 }

        // Nếu ngày học gần nhất trước hôm qua -> Mất streak
        if mostRecent < yesterday {
            return 0
        }

        var streak = 1
        for i in 0..<(uniqueDays.count - 1) {
            let day1 = uniqueDays[i]
            let day2 = uniqueDays[i + 1]
            let diff = calendar.dateComponents([.day], from: day2, to: day1).day ?? 0
            if diff == 1 {
                streak += 1
            } else {
                break
            }
        }
        return streak
    }

    public var latestScore: ToeicScore? {
        scores.sorted(by: { $0.date > $1.date }).first
    }

    public var highestScore: ToeicScore? {
        scores.max(by: { $0.calculateTotal(isFourSkills: isFourSkills) < $1.calculateTotal(isFourSkills: isFourSkills) })
    }

    public var averageScore: Int {
        if scores.isEmpty { return 0 }
        let sum = scores.reduce(0) { $0 + $1.calculateTotal(isFourSkills: isFourSkills) }
        return sum / scores.count
    }

    enum CodingKeys: String, CodingKey {
        case id
        case authUid
        case name
        case dateOfBirth
        case targetScore
        case avatarUrl
        case avatarPath // Flutter mock compatibility
        case isFourSkills
        case scores
        case chatHistory
        case groupId
        case groupRole
        case pendingGroupId
        case isDisabled
        case isAdmin
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        self.authUid = try container.decodeIfPresent(String.self, forKey: .authUid)
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? "Học viên"
        
        if let dateString = try? container.decode(String.self, forKey: .dateOfBirth) {
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let parsed = isoFormatter.date(from: dateString) {
                self.dateOfBirth = parsed
            } else {
                let fallback = ISO8601DateFormatter()
                self.dateOfBirth = fallback.date(from: dateString) ?? Date()
            }
        } else if let dateVal = try? container.decode(Date.self, forKey: .dateOfBirth) {
            self.dateOfBirth = dateVal
        } else {
            self.dateOfBirth = Date()
        }

        self.targetScore = try container.decodeIfPresent(Int.self, forKey: .targetScore) ?? 500
        self.avatarUrl = try container.decodeIfPresent(String.self, forKey: .avatarUrl) ?? container.decodeIfPresent(String.self, forKey: .avatarPath)
        self.isFourSkills = try container.decodeIfPresent(Bool.self, forKey: .isFourSkills) ?? false
        self.scores = try container.decodeIfPresent([ToeicScore].self, forKey: .scores) ?? []
        self.chatHistory = try container.decodeIfPresent([MunAIChatSession].self, forKey: .chatHistory) ?? []
        self.groupId = try container.decodeIfPresent(String.self, forKey: .groupId)
        self.groupRole = try container.decodeIfPresent(String.self, forKey: .groupRole)
        self.pendingGroupId = try container.decodeIfPresent(String.self, forKey: .pendingGroupId)
        self.isDisabled = try container.decodeIfPresent(Bool.self, forKey: .isDisabled) ?? false
        self.isAdmin = try container.decodeIfPresent(Bool.self, forKey: .isAdmin) ?? false
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(authUid, forKey: .authUid)
        try container.encode(name, forKey: .name)
        let isoFormatter = ISO8601DateFormatter()
        try container.encode(isoFormatter.string(from: dateOfBirth), forKey: .dateOfBirth)
        try container.encode(targetScore, forKey: .targetScore)
        try container.encodeIfPresent(avatarUrl, forKey: .avatarUrl)
        try container.encode(isFourSkills, forKey: .isFourSkills)
        try container.encode(scores, forKey: .scores)
        try container.encode(chatHistory, forKey: .chatHistory)
        try container.encodeIfPresent(groupId, forKey: .groupId)
        try container.encodeIfPresent(groupRole, forKey: .groupRole)
        try container.encodeIfPresent(pendingGroupId, forKey: .pendingGroupId)
        try container.encode(isDisabled, forKey: .isDisabled)
        try container.encode(isAdmin, forKey: .isAdmin)
    }
}
