import Foundation

public struct MunAIChatMessage: Identifiable, Codable, Equatable, Hashable {
    public var id: String
    public var role: String // "user" or "model"
    public var text: String
    public var timestamp: Date

    public init(id: String = UUID().uuidString, role: String, text: String, timestamp: Date = Date()) {
        self.id = id
        self.role = role
        self.text = text
        self.timestamp = timestamp
    }

    public var isUser: Bool {
        role.lowercased() == "user"
    }

    enum CodingKeys: String, CodingKey {
        case id
        case role
        case text
        case timestamp
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        self.role = try container.decodeIfPresent(String.self, forKey: .role) ?? "user"
        self.text = try container.decodeIfPresent(String.self, forKey: .text) ?? ""
        if let ts = try? container.decode(Date.self, forKey: .timestamp) {
            self.timestamp = ts
        } else {
            self.timestamp = Date()
        }
    }
}

public struct MunAIChatSession: Identifiable, Codable, Equatable, Hashable {
    public var id: String
    public var title: String
    public var createdAt: Date
    public var messages: [MunAIChatMessage]

    public init(
        id: String = UUID().uuidString,
        title: String = "Cuộc trò chuyện mới",
        createdAt: Date = Date(),
        messages: [MunAIChatMessage] = []
    ) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.messages = messages
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case createdAt
        case messages
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        self.title = try container.decodeIfPresent(String.self, forKey: .title) ?? "Cuộc trò chuyện mới"
        
        if let dateString = try? container.decode(String.self, forKey: .createdAt) {
            let isoFormatter = ISO8601DateFormatter()
            self.createdAt = isoFormatter.date(from: dateString) ?? Date()
        } else if let dateVal = try? container.decode(Date.self, forKey: .createdAt) {
            self.createdAt = dateVal
        } else {
            self.createdAt = Date()
        }

        self.messages = try container.decodeIfPresent([MunAIChatMessage].self, forKey: .messages) ?? []
    }
}
