import Foundation

public struct GroupModel: Identifiable, Codable, Equatable, Hashable {
    public let id: String
    public var name: String
    public var requireApproval: Bool
    public var leaderId: String

    public init(
        id: String,
        name: String,
        requireApproval: Bool = false,
        leaderId: String = ""
    ) {
        self.id = id
        self.name = name
        self.requireApproval = requireApproval
        self.leaderId = leaderId
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case requireApproval
        case leaderId
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? "Nhóm mới"
        self.requireApproval = try container.decodeIfPresent(Bool.self, forKey: .requireApproval) ?? false
        self.leaderId = try container.decodeIfPresent(String.self, forKey: .leaderId) ?? ""
    }
}
