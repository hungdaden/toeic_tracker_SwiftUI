import Foundation

public final class StorageService {
    public static let shared = StorageService()
    private let activeUserIdKey = "toeic_active_user_id"
    private let geminiApiKeyKey = "toeic_gemini_api_key"

    private init() {}

    public func getActiveUserId() -> String? {
        UserDefaults.standard.string(forKey: activeUserIdKey)
    }

    public func setActiveUserId(_ id: String?) {
        UserDefaults.standard.set(id, forKey: activeUserIdKey)
    }

    public func getGeminiApiKey() -> String {
        UserDefaults.standard.string(forKey: geminiApiKeyKey) ?? ""
    }

    public func setGeminiApiKey(_ key: String) {
        UserDefaults.standard.set(key, forKey: geminiApiKeyKey)
    }
}
