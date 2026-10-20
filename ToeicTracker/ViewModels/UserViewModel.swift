import Foundation
import SwiftUI
import Combine

public enum AppNotificationType {
    case success
    case warning
    case info
    case error

    public var color: Color {
        switch self {
        case .success: return LiquidGlassTheme.scoreTotal
        case .warning: return LiquidGlassTheme.amberAccent
        case .info: return LiquidGlassTheme.secondaryAccent
        case .error: return LiquidGlassTheme.roseAccent
        }
    }

    public var systemIcon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info: return "info.circle.fill"
        case .error: return "xmark.octagon.fill"
        }
    }
}

public struct AppBannerNotification: Identifiable, Equatable {
    public let id = UUID()
    public let title: String
    public let message: String
    public let type: AppNotificationType
}

@MainActor
public final class UserViewModel: ObservableObject {
    @Published public var users: [UserModel] = []
    @Published public var currentUserId: String?
    @Published public var isLoading: Bool = false
    @Published public var activeNotification: AppBannerNotification?
    @Published public var showAimHitConfetti: Bool = false

    public let authService = AuthService.shared
    private let firestore = FirestoreService.shared
    private let storage = StorageService.shared
    private var cancellables = Set<AnyCancellable>()
    private var syncTimer: Timer?

    public init() {
        setupAuthListener()
    }

    private func setupAuthListener() {
        authService.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] authUser in
                guard let self else { return }
                if let authUser {
                    Task {
                        await self.loadFirestoreUsers(authUid: authUser.uid, idToken: authUser.idToken)
                    }
                    self.startPeriodicSync()
                } else {
                    self.users = []
                    self.currentUserId = nil
                    self.stopPeriodicSync()
                }
            }
            .store(in: &cancellables)
    }

    public var currentUser: UserModel? {
        guard let currentUserId else { return users.first }
        return users.first(where: { $0.id == currentUserId }) ?? users.first
    }

    // MARK: - Firestore Operations
    public func loadFirestoreUsers(authUid: String? = nil, idToken: String? = nil) async {
        guard let uid = authUid ?? authService.currentUser?.uid else { return }
        let refreshedToken = await authService.refreshTokenIfNeeded()
        let token = idToken ?? refreshedToken ?? ""

        isLoading = true
        defer { isLoading = false }

        do {
            let loaded = try await firestore.fetchUsers(authUid: uid, idToken: token)
            self.users = loaded

            let savedActiveId = storage.getActiveUserId()
            if let savedActiveId, loaded.contains(where: { $0.id == savedActiveId }) {
                self.currentUserId = savedActiveId
            } else {
                self.currentUserId = loaded.first?.id
                storage.setActiveUserId(self.currentUserId)
            }
        } catch {
            print("Failed to fetch users from Firestore: \(error)")
        }
    }

    public func switchUser(to id: String) {
        guard users.contains(where: { $0.id == id }) else { return }
        currentUserId = id
        storage.setActiveUserId(id)
        if let user = currentUser {
            showNotification(title: "Chuyển hồ sơ", message: "Đang xem hồ sơ của \(user.name)", type: .info)
        }
    }

    public func addUser(name: String, targetScore: Int, dateOfBirth: Date, isFourSkills: Bool = false) {
        guard let authUser = authService.currentUser else {
            showNotification(title: "Chưa đăng nhập", message: "Vui lòng đăng nhập để tạo hồ sơ.", type: .warning)
            return
        }

        let newUser = UserModel(
            id: UUID().uuidString,
            authUid: authUser.uid,
            name: name,
            dateOfBirth: dateOfBirth,
            targetScore: targetScore,
            isFourSkills: isFourSkills
        )

        users.append(newUser)
        currentUserId = newUser.id
        storage.setActiveUserId(newUser.id)

        Task {
            let refreshed = await authService.refreshTokenIfNeeded()
            let token = refreshed ?? authUser.idToken
            do {
                try await firestore.saveUser(newUser, idToken: token)
                showNotification(title: "Thành công", message: "Đã lưu hồ sơ \(name) lên Firebase Cloud!", type: .success)
            } catch {
                showNotification(title: "Lỗi đồng bộ", message: "Không thể lưu lên Firebase: \(error.localizedDescription)", type: .error)
            }
        }
    }

    public func updateUser(_ updated: UserModel) {
        if let idx = users.firstIndex(where: { $0.id == updated.id }) {
            users[idx] = updated

            Task {
                guard let token = await authService.refreshTokenIfNeeded() else { return }
                do {
                    try await firestore.saveUser(updated, idToken: token)
                    showNotification(title: "Đã cập nhật", message: "Thông tin hồ sơ đã đồng bộ lên Firebase", type: .success)
                } catch {
                    print("Error updating user on Firestore: \(error)")
                }
            }
        }
    }

    public func deleteUser(id: String) {
        users.removeAll(where: { $0.id == id })
        if currentUserId == id {
            currentUserId = users.first?.id
            storage.setActiveUserId(currentUserId)
        }

        Task {
            guard let token = await authService.refreshTokenIfNeeded() else { return }
            do {
                try await firestore.deleteUser(userId: id, idToken: token)
                showNotification(title: "Đã xóa", message: "Đã xóa hồ sơ trên hệ thống", type: .info)
            } catch {
                print("Error deleting user on Firestore: \(error)")
            }
        }
    }

    public func addScore(_ score: ToeicScore) -> Bool {
        guard let currentUserId, let idx = users.firstIndex(where: { $0.id == currentUserId }) else { return false }
        users[idx].scores.append(score)

        let updatedUser = users[idx]
        let target = updatedUser.targetScore
        let total = score.calculateTotal(isFourSkills: updatedUser.isFourSkills)
        let isHitAim = total >= target

        if isHitAim {
            showAimHitConfetti = true
            showNotification(title: "🎉 ĐẠT MỤC TIÊU!", message: "Chúc mừng bạn đạt \(total) điểm!", type: .success)
        } else {
            showNotification(title: "Thành công", message: "Đã lưu bài thi: \(total) điểm lên Firebase!", type: .success)
        }

        Task {
            guard let token = await authService.refreshTokenIfNeeded() else { return }
            try? await firestore.saveUser(updatedUser, idToken: token)
        }

        return isHitAim
    }

    public func updateScore(_ score: ToeicScore) {
        guard let currentUserId, let uIdx = users.firstIndex(where: { $0.id == currentUserId }) else { return }
        if let sIdx = users[uIdx].scores.firstIndex(where: { $0.id == score.id }) {
            users[uIdx].scores[sIdx] = score
            let updatedUser = users[uIdx]

            Task {
                guard let token = await authService.refreshTokenIfNeeded() else { return }
                try? await firestore.saveUser(updatedUser, idToken: token)
                showNotification(title: "Đã cập nhật", message: "Điểm thi đã cập nhật trên Firebase", type: .success)
            }
        }
    }

    public func deleteScore(id: String) {
        guard let currentUserId, let uIdx = users.firstIndex(where: { $0.id == currentUserId }) else { return }
        users[uIdx].scores.removeAll(where: { $0.id == id })
        let updatedUser = users[uIdx]

        Task {
            guard let token = await authService.refreshTokenIfNeeded() else { return }
            try? await firestore.saveUser(updatedUser, idToken: token)
            showNotification(title: "Đã xóa", message: "Đã xóa điểm thi", type: .info)
        }
    }

    public func toggleFourSkills() {
        guard let currentUserId, let uIdx = users.firstIndex(where: { $0.id == currentUserId }) else { return }
        users[uIdx].isFourSkills.toggle()
        let updatedUser = users[uIdx]

        let mode = updatedUser.isFourSkills ? "4 kỹ năng (Nghe, Đọc, Nói, Viết)" : "2 kỹ năng (Nghe, Đọc)"
        showNotification(title: "Chế độ thi", message: "Đã chuyển sang \(mode)", type: .info)

        Task {
            guard let token = await authService.refreshTokenIfNeeded() else { return }
            try? await firestore.saveUser(updatedUser, idToken: token)
        }
    }

    public func showNotification(title: String, message: String, type: AppNotificationType) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            self.activeNotification = AppBannerNotification(title: title, message: message, type: type)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { [weak self] in
            guard let self else { return }
            withAnimation(.easeInOut(duration: 0.25)) {
                if self.activeNotification?.title == title {
                    self.activeNotification = nil
                }
            }
        }
    }

    private func startPeriodicSync() {
        stopPeriodicSync()
        syncTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task {
                await self.loadFirestoreUsers()
            }
        }
    }

    private func stopPeriodicSync() {
        syncTimer?.invalidate()
        syncTimer = nil
    }
}
