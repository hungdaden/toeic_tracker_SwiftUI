import Foundation
import SwiftUI
import Combine

public final class MunAIViewModel: ObservableObject {
    @Published public var sessions: [MunAIChatSession] = []
    @Published public var currentSession: MunAIChatSession
    @Published public var isThinking: Bool = false
    @Published public var showDrawer: Bool = false
    @Published public var inputMessage: String = ""

    public let suggestions: [String] = [
        "🎯 Tư vấn lộ trình đạt mục tiêu điểm của mình",
        "🎧 Mẹo tránh bẫy câu hỏi Part 2",
        "📖 Chiến lược làm bài đọc Part 7 kịp giờ",
        "📊 Phân tích điểm thi gần nhất của mình",
        "💡 10 cụm từ đồng nghĩa hay gặp trong đề thi"
    ]

    private let geminiService = GeminiAIService.shared
    private let storage = StorageService.shared

    public init() {
        let initialSession = MunAIChatSession(
            messages: [
                MunAIChatMessage(
                    role: "model",
                    text: "Chào bạn! Mình là Mun AI 🐱. Mình đã sẵn sàng cùng bạn phân tích kết quả và chinh phục điểm TOEIC mục tiêu rồi đây!"
                )
            ]
        )
        self.currentSession = initialSession
        self.sessions = [initialSession]
    }

    public func loadUserChatHistory(user: UserModel?) {
        if let user, !user.chatHistory.isEmpty {
            self.sessions = user.chatHistory
            self.currentSession = user.chatHistory.first ?? currentSession
        }
    }

    public func createNewSession() {
        let newSession = MunAIChatSession(
            messages: [
                MunAIChatMessage(
                    role: "model",
                    text: "Chào bạn! Mình là Mun AI 🐱. Mun đã mở phiên tư vấn mới. Bạn muốn học hay thắc mắc về phần nào hôm nay?"
                )
            ]
        )
        sessions.insert(newSession, at: 0)
        currentSession = newSession
        showDrawer = false
    }

    public func switchSession(to session: MunAIChatSession) {
        currentSession = session
        showDrawer = false
    }

    public func deleteSession(id: String) {
        sessions.removeAll(where: { $0.id == id })
        if currentSession.id == id {
            if let first = sessions.first {
                currentSession = first
            } else {
                createNewSession()
            }
        }
    }

    @MainActor
    public func sendMessage(text: String, currentUser: UserModel?) async {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // Append user message
        let userMsg = MunAIChatMessage(role: "user", text: trimmed)
        currentSession.messages.append(userMsg)
        inputMessage = ""
        isThinking = true

        // Update session title if first user message
        if currentSession.title == "Cuộc trò chuyện mới" {
            currentSession.title = String(trimmed.prefix(28))
        }

        // Call Gemini service
        let apiKey = storage.getGeminiApiKey()
        let reply = await geminiService.sendMessage(
            prompt: trimmed,
            history: currentSession.messages,
            currentUser: currentUser,
            apiKey: apiKey
        )

        let aiMsg = MunAIChatMessage(role: "model", text: reply)
        currentSession.messages.append(aiMsg)
        isThinking = false

        // Update in sessions list
        if let idx = sessions.firstIndex(where: { $0.id == currentSession.id }) {
            sessions[idx] = currentSession
        }
    }
}
