import Foundation

public final class FirestoreService {
    public static let shared = FirestoreService()
    private let config = FirebaseConfig.shared

    private init() {}

    // MARK: - Fetch Users for Auth UID
    public func fetchUsers(authUid: String, idToken: String) async throws -> [UserModel] {
        guard let url = URL(string: "\(config.firestoreBaseURL):runQuery?key=\(config.apiKey)") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")

        let queryPayload: [String: Any] = [
            "structuredQuery": [
                "from": [["collectionId": "users"]],
                "where": [
                    "fieldFilter": [
                        "field": ["fieldPath": "authUid"],
                        "op": "EQUAL",
                        "value": ["stringValue": authUid]
                    ]
                ]
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: queryPayload)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpRes = response as? HTTPURLResponse, httpRes.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        guard let results = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return []
        }

        var users: [UserModel] = []
        for item in results {
            if let document = item["document"] as? [String: Any],
               let fields = document["fields"] as? [String: Any] {
                if let user = parseUser(from: fields) {
                    users.append(user)
                }
            }
        }

        return users
    }

    // MARK: - Save / Update User
    public func saveUser(_ user: UserModel, idToken: String) async throws {
        guard let url = URL(string: "\(config.firestoreBaseURL)/users/\(user.id)?key=\(config.apiKey)") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")

        let fields = encodeUser(user)
        let body: [String: Any] = ["fields": fields]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpRes = response as? HTTPURLResponse, (httpRes.statusCode == 200 || httpRes.statusCode == 201) else {
            throw URLError(.badServerResponse)
        }
    }

    // MARK: - Delete User
    public func deleteUser(userId: String, idToken: String) async throws {
        guard let url = URL(string: "\(config.firestoreBaseURL)/users/\(userId)?key=\(config.apiKey)") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")

        _ = try await URLSession.shared.data(for: request)
    }

    // MARK: - Fetch System Config
    public func fetchSystemConfig() async throws -> (maintenanceMode: Bool, aiModel: String, aiSystemPrompt: String) {
        guard let url = URL(string: "\(config.firestoreBaseURL)/config/system?key=\(config.apiKey)") else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpRes = response as? HTTPURLResponse, httpRes.statusCode == 200,
              let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let fields = json["fields"] as? [String: Any] else {
            return (false, "gemini-2.0-flash", "")
        }

        let isMaintenance = (fields["maintenanceMode"] as? [String: Any])?["booleanValue"] as? Bool ?? false
        let model = (fields["aiModel"] as? [String: Any])?["stringValue"] as? String ?? "gemini-2.0-flash"
        let prompt = (fields["aiSystemPrompt"] as? [String: Any])?["stringValue"] as? String ?? ""

        return (isMaintenance, model, prompt)
    }

    // MARK: - Field Encoding Helpers
    private func encodeUser(_ user: UserModel) -> [String: Any] {
        var fields: [String: Any] = [:]

        fields["id"] = ["stringValue": user.id]
        if let authUid = user.authUid {
            fields["authUid"] = ["stringValue": authUid]
        }
        fields["name"] = ["stringValue": user.name]

        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        fields["dateOfBirth"] = ["stringValue": iso.string(from: user.dateOfBirth)]
        fields["targetScore"] = ["integerValue": "\(user.targetScore)"]
        fields["isFourSkills"] = ["booleanValue": user.isFourSkills]
        fields["isDisabled"] = ["booleanValue": user.isDisabled]
        fields["isAdmin"] = ["booleanValue": user.isAdmin]

        if let gId = user.groupId { fields["groupId"] = ["stringValue": gId] }
        if let gRole = user.groupRole { fields["groupRole"] = ["stringValue": gRole] }
        if let pGId = user.pendingGroupId { fields["pendingGroupId"] = ["stringValue": pGId] }
        if let aUrl = user.avatarUrl { fields["avatarUrl"] = ["stringValue": aUrl] }

        // Encode Scores
        var scoreValues: [[String: Any]] = []
        for s in user.scores {
            var sMap: [String: Any] = [
                "id": ["stringValue": s.id],
                "date": ["stringValue": iso.string(from: s.date)],
                "listeningScore": ["integerValue": "\(s.listeningScore)"],
                "readingScore": ["integerValue": "\(s.readingScore)"]
            ]
            if let sp = s.speakingScore { sMap["speakingScore"] = ["integerValue": "\(sp)"] }
            if let wr = s.writingScore { sMap["writingScore"] = ["integerValue": "\(wr)"] }
            scoreValues.append(["mapValue": ["fields": sMap]])
        }
        fields["scores"] = ["arrayValue": ["values": scoreValues]]

        // Encode Chat History
        var chatValues: [[String: Any]] = []
        for c in user.chatHistory {
            var msgValues: [[String: Any]] = []
            for m in c.messages {
                msgValues.append([
                    "mapValue": [
                        "fields": [
                            "role": ["stringValue": m.role],
                            "text": ["stringValue": m.text]
                        ]
                    ]
                ])
            }
            let cMap: [String: Any] = [
                "id": ["stringValue": c.id],
                "title": ["stringValue": c.title],
                "createdAt": ["stringValue": iso.string(from: c.createdAt)],
                "messages": ["arrayValue": ["values": msgValues]]
            ]
            chatValues.append(["mapValue": ["fields": cMap]])
        }
        fields["chatHistory"] = ["arrayValue": ["values": chatValues]]

        return fields
    }

    // MARK: - Field Decoding Helpers
    private func parseUser(from fields: [String: Any]) -> UserModel? {
        guard let id = (fields["id"] as? [String: Any])?["stringValue"] as? String,
              let name = (fields["name"] as? [String: Any])?["stringValue"] as? String else {
            return nil
        }

        let authUid = (fields["authUid"] as? [String: Any])?["stringValue"] as? String
        let targetScoreStr = (fields["targetScore"] as? [String: Any])?["integerValue"] as? String
        let targetScore = Int(targetScoreStr ?? "500") ?? 500
        let isFourSkills = (fields["isFourSkills"] as? [String: Any])?["booleanValue"] as? Bool ?? false
        let isDisabled = (fields["isDisabled"] as? [String: Any])?["booleanValue"] as? Bool ?? false
        let isAdmin = (fields["isAdmin"] as? [String: Any])?["booleanValue"] as? Bool ?? false
        let groupId = (fields["groupId"] as? [String: Any])?["stringValue"] as? String
        let groupRole = (fields["groupRole"] as? [String: Any])?["stringValue"] as? String
        let pendingGroupId = (fields["pendingGroupId"] as? [String: Any])?["stringValue"] as? String
        let avatarUrl = (fields["avatarUrl"] as? [String: Any])?["stringValue"] as? String

        let dobStr = (fields["dateOfBirth"] as? [String: Any])?["stringValue"] as? String ?? ""
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let dateOfBirth = iso.date(from: dobStr) ?? ISO8601DateFormatter().date(from: dobStr) ?? Date()

        // Parse scores
        var scores: [ToeicScore] = []
        if let sArray = (fields["scores"] as? [String: Any])?["arrayValue"] as? [String: Any],
           let sValues = sArray["values"] as? [[String: Any]] {
            for v in sValues {
                if let sFields = (v["mapValue"] as? [String: Any])?["fields"] as? [String: Any] {
                    let sId = (sFields["id"] as? [String: Any])?["stringValue"] as? String ?? UUID().uuidString
                    let sDateStr = (sFields["date"] as? [String: Any])?["stringValue"] as? String ?? ""
                    let sDate = iso.date(from: sDateStr) ?? ISO8601DateFormatter().date(from: sDateStr) ?? Date()
                    let lScoreStr = (sFields["listeningScore"] as? [String: Any])?["integerValue"] as? String ?? "0"
                    let rScoreStr = (sFields["readingScore"] as? [String: Any])?["integerValue"] as? String ?? "0"
                    let spStr = (sFields["speakingScore"] as? [String: Any])?["integerValue"] as? String
                    let wrStr = (sFields["writingScore"] as? [String: Any])?["integerValue"] as? String

                    scores.append(ToeicScore(
                        id: sId,
                        date: sDate,
                        listeningScore: Int(lScoreStr) ?? 0,
                        readingScore: Int(rScoreStr) ?? 0,
                        speakingScore: spStr != nil ? Int(spStr!) : nil,
                        writingScore: wrStr != nil ? Int(wrStr!) : nil
                    ))
                }
            }
        }

        // Parse chatHistory
        var chatHistory: [MunAIChatSession] = []
        if let cArray = (fields["chatHistory"] as? [String: Any])?["arrayValue"] as? [String: Any],
           let cValues = cArray["values"] as? [[String: Any]] {
            for v in cValues {
                if let cFields = (v["mapValue"] as? [String: Any])?["fields"] as? [String: Any] {
                    let cId = (cFields["id"] as? [String: Any])?["stringValue"] as? String ?? UUID().uuidString
                    let cTitle = (cFields["title"] as? [String: Any])?["stringValue"] as? String ?? "Cuộc trò chuyện"
                    let cDateStr = (cFields["createdAt"] as? [String: Any])?["stringValue"] as? String ?? ""
                    let cDate = iso.date(from: cDateStr) ?? Date()

                    var msgs: [MunAIChatMessage] = []
                    if let mArray = (cFields["messages"] as? [String: Any])?["arrayValue"] as? [String: Any],
                       let mValues = mArray["values"] as? [[String: Any]] {
                        for mv in mValues {
                            if let mFields = (mv["mapValue"] as? [String: Any])?["fields"] as? [String: Any] {
                                let role = (mFields["role"] as? [String: Any])?["stringValue"] as? String ?? "user"
                                let text = (mFields["text"] as? [String: Any])?["stringValue"] as? String ?? ""
                                msgs.append(MunAIChatMessage(role: role, text: text))
                            }
                        }
                    }

                    chatHistory.append(MunAIChatSession(
                        id: cId,
                        title: cTitle,
                        createdAt: cDate,
                        messages: msgs
                    ))
                }
            }
        }

        return UserModel(
            id: id,
            authUid: authUid,
            name: name,
            dateOfBirth: dateOfBirth,
            targetScore: targetScore,
            avatarUrl: avatarUrl,
            isFourSkills: isFourSkills,
            scores: scores,
            chatHistory: chatHistory,
            groupId: groupId,
            groupRole: groupRole,
            pendingGroupId: pendingGroupId,
            isDisabled: isDisabled,
            isAdmin: isAdmin
        )
    }
}
