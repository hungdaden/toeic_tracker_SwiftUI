import Foundation

public final class GeminiAIService {
    public static let shared = GeminiAIService()
    private init() {}

    public func sendMessage(
        prompt: String,
        history: [MunAIChatMessage],
        currentUser: UserModel?,
        apiKey: String
    ) async -> String {
        let cleanKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)

        if !cleanKey.isEmpty {
            do {
                let response = try await callGeminiAPI(
                    prompt: prompt,
                    history: history,
                    currentUser: currentUser,
                    apiKey: cleanKey
                )
                if !response.isEmpty {
                    return response
                }
            } catch {
                print("Gemini API call failed: \(error), falling back to offline assistant.")
            }
        }

        // Offline intelligent assistant fallback
        return generateOfflineResponse(prompt: prompt, currentUser: currentUser)
    }

    private func callGeminiAPI(
        prompt: String,
        history: [MunAIChatMessage],
        currentUser: UserModel?,
        apiKey: String
    ) async throws -> String {
        let model = "gemini-2.0-flash"
        guard let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent?key=\(apiKey)") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Build context
        var systemInstruction = "Bạn là Mun AI 🐱, trợ lý học tập TOEIC thông minh, tận tình và thân thiện. Hãy trả lời chuyên nghiệp, súc tích, truyền cảm hứng và luôn dùng tiếng Việt tự nhiên."
        if let user = currentUser {
            let latest = user.latestScore
            let latestListening = latest?.listeningScore ?? 0
            let latestReading = latest?.readingScore ?? 0
            let total = latest?.calculateTotal(isFourSkills: user.isFourSkills) ?? 0

            systemInstruction += """
            
            Thông tin học viên hiện tại:
            - Tên: \(user.name)
            - Mục tiêu TOEIC: \(user.targetScore) điểm
            - Điểm gần nhất: Tổng \(total) (Nghe: \(latestListening), Đọc: \(latestReading))
            - Chuỗi ngày học liên tiếp (Streak): \(user.currentStreak) ngày
            Hãy cá nhân hóa lời khuyên theo số điểm và mục tiêu của học viên.
            """
        }

        // Build contents payload
        var contents: [[String: Any]] = []

        // Include recent history (last 6 messages)
        let recent = history.suffix(6)
        for msg in recent {
            contents.append([
                "role": msg.isUser ? "user" : "model",
                "parts": [["text": msg.text]]
            ])
        }

        // Add current prompt
        contents.append([
            "role": "user",
            "parts": [["text": prompt]]
        ])

        let payload: [String: Any] = [
            "system_instruction": [
                "parts": [["text": systemInstruction]]
            ],
            "contents": contents,
            "generationConfig": [
                "temperature": 0.7,
                "maxOutputTokens": 1024
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: payload)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let candidates = json["candidates"] as? [[String: Any]],
           let firstCandidate = candidates.first,
           let content = firstCandidate["content"] as? [String: Any],
           let parts = content["parts"] as? [[String: Any]],
           let firstPart = parts.first,
           let text = firstPart["text"] as? String {
            return text
        }

        throw URLError(.cannotParseResponse)
    }

    private func generateOfflineResponse(prompt: String, currentUser: UserModel?) -> String {
        let p = prompt.lowercased()
        let name = currentUser?.name ?? "bạn"
        let target = currentUser?.targetScore ?? 750
        let latest = currentUser?.latestScore
        let total = latest?.calculateTotal(isFourSkills: currentUser?.isFourSkills ?? false) ?? 0
        let listening = latest?.listeningScore ?? 0
        let reading = latest?.readingScore ?? 0

        if p.contains("lộ trình") || p.contains("kế hoạch") || p.contains("mục tiêu") {
            let gap = max(target - total, 0)
            return """
            Chào \(name) 🐱! Mun đã xem qua hồ sơ của bạn:
            🎯 Điểm mục tiêu: **\(target) điểm**
            📊 Điểm gần nhất: **\(total)** (Nghe: \(listening) | Đọc: \(reading))
            📈 Khoảng cách cần bứt phá: **+\(gap) điểm**

            💡 **Lộ trình trọng tâm Mun đề xuất cho bạn:**
            1. **Giai đoạn 1 (Tuần 1 - 2):** Khóa chặt điểm Part 1 & 2. Luyện phản xạ nghe từ khóa, bẫy đồng âm và câu trả lời gián tiếp.
            2. **Giai đoạn 2 (Tuần 3 - 4):** Tối ưu ngữ pháp Part 5 & 6, đặt mục tiêu giải mỗi câu dưới 30 giây để dành thời gian cho Part 7.
            3. **Giai đoạn 3 (Tuần 5 - 6):** Rèn luyện kỹ thuật Scanning & Skimming cho Part 7 đoạn đơn và đoạn kép.
            4. **Mỗi tuần làm 1 đề thi ETS 2026** ngay trên app để quen với áp lực bấm giờ 120 phút nhé!
            """
        }

        if p.contains("part 7") || p.contains("đọc") || p.contains("reading") {
            return """
            🐱 **Mẹo chinh phục Part 7 từ Mun:**
            1. **Đọc câu hỏi trước:** Xác định rõ câu hỏi hỏi về *chi tiết cụ thể* (Specific), *ý chính* (Main idea), hay *suy luận* (Inference).
            2. **Chiến thuật làm ngược:** Khi thời gian còn ít, hãy cân nhắc làm các bài đoạn đôi/đoạn ba (176-200) trước khi não còn tỉnh táo!
            3. **Không dịch từng từ:** Quét nhanh (Scanning) để tìm tên riêng, con số, thời gian tương ứng trong câu hỏi.
            4. **Cảnh giác bẫy từ đồng nghĩa (Paraphrasing):** ETS luôn thay đổi từ trong bài đọc bằng từ đồng nghĩa ở đáp án đúng!
            """
        }

        if p.contains("part 2") || p.contains("part 1") || p.contains("nghe") || p.contains("listening") {
            return """
            🐱 **Bí quyết Part 1 & 2 để đạt trên 400+ Listening:**
            1. **Quy tắc Part 2:**
               - Bẫy lặp từ/từ phát âm tương tự (Same/similar sound) -> 90% là bẫy SAI!
               - Câu hỏi *Wh-* (Who, Where, When...) KHÔNG bao giờ trả lời bằng Yes/No.
               - Câu trả lời gián tiếp ("Tôi không rõ", "Hỏi chị Mary xem") rất thường là đáp án đúng.
            2. **Part 1:** Chú ý thì Hiện tại tiếp diễn bị động (*being + V3*) chỉ đúng khi có người đang trực tiếp tác động vào vật!
            """
        }

        if p.contains("phân tích") || p.contains("điểm") || p.contains("đánh giá") {
            let weak = listening < reading ? "Listening" : "Reading"
            return """
            🐱 **Mun AI phân tích kết quả gần nhất của \(name):**
            - Nghe (Listening): **\(listening)/495**
            - Đọc (Reading): **\(reading)/495**
            - Tổng điểm: **\(total)/990**
            - Chuỗi học tập: **\(currentUser?.currentStreak ?? 0) ngày liên tiếp 🔥**

            👉 Nhận định: Phần **\(weak)** của bạn còn nhiều dư địa tăng điểm nhất. Mun khuyên bạn nên làm thêm 1 bài thi thử ETS 2026 trong tab **Bài thi** để cọ xát trực tiếp nhé!
            """
        }

        return """
        Chào \(name) 🐱! Mun luôn ở đây để đồng hành cùng bạn trên con đường chinh phục \(target)+ TOEIC!

        Bạn có thể hỏi Mun về:
        • Phân tích điểm mạnh/yếu dựa trên kết quả thi của bạn
        • Lộ trình tự học từ \(total) lên \(target) điểm
        • Mẹo tránh bẫy Part 2, chiến thuật đọc nhanh Part 7
        • Kế hoạch bấm giờ chuẩn ETS 120 phút.

        Bạn muốn Mun hỗ trợ nội dung nào trước nhé?
        """
    }
}
