import Foundation
import Combine

public struct AuthUser: Codable, Equatable {
    public let uid: String
    public let email: String
    public var idToken: String
    public var refreshToken: String

    public init(uid: String, email: String, idToken: String, refreshToken: String) {
        self.uid = uid
        self.email = email
        self.idToken = idToken
        self.refreshToken = refreshToken
    }
}

@MainActor
public final class AuthService: ObservableObject {
    public static let shared = AuthService()

    @Published public var currentUser: AuthUser?
    @Published public var isAuthenticated: Bool = false
    @Published public var isLoading: Bool = false
    @Published public var isMaintenanceMode: Bool = false

    private let config = FirebaseConfig.shared
    private let authStorageKey = "toeic_firebase_auth_user"

    private init() {
        loadPersistedSession()
        Task {
            await checkMaintenanceMode()
        }
    }

    public func checkMaintenanceMode() async {
        guard let url = URL(string: "\(config.firestoreBaseURL)/config/system?key=\(config.apiKey)") else { return }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            if let httpRes = response as? HTTPURLResponse, httpRes.statusCode == 200,
               let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let fields = json["fields"] as? [String: Any],
               let mMode = fields["maintenanceMode"] as? [String: Any],
               let isMaintenance = mMode["booleanValue"] as? Bool {
                self.isMaintenanceMode = isMaintenance
            }
        } catch {
            print("Failed to check maintenance mode: \(error)")
        }
    }

    public func signIn(emailOrUsername: String, password: String) async -> String? {
        await checkMaintenanceMode()
        if isMaintenanceMode {
            return "Hệ thống đang bảo trì để nâng cấp. Vui lòng quay lại sau ít phút."
        }

        isLoading = true
        defer { isLoading = false }

        let cleanInput = emailOrUsername.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalEmail = cleanInput.contains("@") ? cleanInput : "\(cleanInput)@toeic.app"

        guard let url = URL(string: "\(config.authBaseURL)/accounts:signInWithPassword?key=\(config.apiKey)") else {
            return "URL không hợp lệ."
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "email": finalEmail,
            "password": password,
            "returnSecureToken": true
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpRes = response as? HTTPURLResponse else {
                return "Không thể kết nối đến máy chủ."
            }

            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]

            if httpRes.statusCode == 200 {
                guard let uid = json["localId"] as? String,
                      let idToken = json["idToken"] as? String,
                      let refreshToken = json["refreshToken"] as? String else {
                    return "Dữ liệu đăng nhập không hợp lệ."
                }

                let user = AuthUser(
                    uid: uid,
                    email: json["email"] as? String ?? finalEmail,
                    idToken: idToken,
                    refreshToken: refreshToken
                )

                self.currentUser = user
                self.isAuthenticated = true
                saveSession(user)
                return nil // Thành công
            } else {
                if let errorObj = json["error"] as? [String: Any],
                   let message = errorObj["message"] as? String {
                    return translateAuthError(message)
                }
                return "Đăng nhập thất bại. Vui lòng kiểm tra lại thông tin."
            }
        } catch {
            return "Lỗi kết nối: \(error.localizedDescription)"
        }
    }

    public func signUp(emailOrUsername: String, password: String) async -> String? {
        isLoading = true
        defer { isLoading = false }

        let cleanInput = emailOrUsername.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalEmail = cleanInput.contains("@") ? cleanInput : "\(cleanInput)@toeic.app"

        guard let url = URL(string: "\(config.authBaseURL)/accounts:signUp?key=\(config.apiKey)") else {
            return "URL không hợp lệ."
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "email": finalEmail,
            "password": password,
            "returnSecureToken": true
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpRes = response as? HTTPURLResponse else {
                return "Không thể kết nối đến máy chủ."
            }

            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]

            if httpRes.statusCode == 200 {
                guard let uid = json["localId"] as? String,
                      let idToken = json["idToken"] as? String,
                      let refreshToken = json["refreshToken"] as? String else {
                    return "Dữ liệu đăng ký không hợp lệ."
                }

                let user = AuthUser(
                    uid: uid,
                    email: json["email"] as? String ?? finalEmail,
                    idToken: idToken,
                    refreshToken: refreshToken
                )

                self.currentUser = user
                self.isAuthenticated = true
                saveSession(user)
                return nil
            } else {
                if let errorObj = json["error"] as? [String: Any],
                   let message = errorObj["message"] as? String {
                    return translateAuthError(message)
                }
                return "Đăng ký thất bại. Vui lòng thử lại."
            }
        } catch {
            return "Lỗi kết nối: \(error.localizedDescription)"
        }
    }

    public func refreshTokenIfNeeded() async -> String? {
        guard let refreshToken = currentUser?.refreshToken else { return nil }
        guard let url = URL(string: "https://securetoken.googleapis.com/v1/token?key=\(config.apiKey)") else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let bodyString = "grant_type=refresh_token&refresh_token=\(refreshToken)"
        request.httpBody = bodyString.data(using: .utf8)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpRes = response as? HTTPURLResponse, httpRes.statusCode == 200,
               let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let newIdToken = json["id_token"] as? String,
               let newRefreshToken = json["refresh_token"] as? String {
                self.currentUser?.idToken = newIdToken
                self.currentUser?.refreshToken = newRefreshToken
                if let user = self.currentUser {
                    saveSession(user)
                }
                return newIdToken
            }
        } catch {
            print("Failed to refresh token: \(error)")
        }
        return currentUser?.idToken
    }

    public func signOut() {
        currentUser = nil
        isAuthenticated = false
        UserDefaults.standard.removeObject(forKey: authStorageKey)
    }

    private func saveSession(_ user: AuthUser) {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: authStorageKey)
        }
    }

    private func loadPersistedSession() {
        if let data = UserDefaults.standard.data(forKey: authStorageKey),
           let user = try? JSONDecoder().decode(AuthUser.self, from: data) {
            self.currentUser = user
            self.isAuthenticated = true
            Task {
                _ = await refreshTokenIfNeeded()
            }
        }
    }

    private func translateAuthError(_ msg: String) -> String {
        if msg.contains("EMAIL_NOT_FOUND") || msg.contains("INVALID_LOGIN_CREDENTIALS") {
            return "Email hoặc mật khẩu không chính xác."
        }
        if msg.contains("INVALID_PASSWORD") {
            return "Mật khẩu không chính xác."
        }
        if msg.contains("EMAIL_EXISTS") {
            return "Tài khoản hoặc email này đã được sử dụng."
        }
        if msg.contains("USER_DISABLED") {
            return "Tài khoản đã bị quản trị viên tạm khóa."
        }
        if msg.contains("TOO_MANY_ATTEMPTS_TRY_LATER") {
            return "Đăng nhập sai quá nhiều lần. Vui lòng thử lại sau."
        }
        if msg.contains("WEAK_PASSWORD") {
            return "Mật khẩu quá ngắn (tối thiểu 6 ký tự)."
        }
        return msg
    }
}
