import SwiftUI

public struct ProfileView: View {
    @ObservedObject public var userVM: UserViewModel

    @State private var showAddUserSheet: Bool = false
    @State private var userToEdit: UserModel?

    private var currentUser: UserModel? {
        userVM.currentUser
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                headerBar

                // Active Profile Hero
                if let user = currentUser {
                    activeProfileCard(user: user)
                } else if !userVM.users.isEmpty {
                    VStack(spacing: 8) {
                        Text("Chưa chọn hồ sơ học viên.")
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .liquidGlassCard(cornerRadius: 20, padding: 18)
                } else {
                    // Empty state: no profile yet
                    emptyProfileCard
                }

                // Profile Switcher Section
                profilesSection

                // Preferences & Utilities
                utilitiesSection

                // App Info & Sign Out
                accountSection

                Spacer().frame(height: 100)
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
        }
        .liquidGlassBackground()
        .sheet(isPresented: $showAddUserSheet) {
            AddUserSheet(userVM: userVM)
        }
        .sheet(item: $userToEdit) { user in
            EditUserSheet(user: user, userVM: userVM)
        }
    }

    // MARK: - Header Bar
    private var headerBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hồ Sơ Học Tập")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)

                if let email = userVM.authService.currentUser?.email {
                    Text("Đã đăng nhập: \(email)")
                        .font(.system(size: 12))
                        .foregroundStyle(LiquidGlassTheme.secondaryAccent)
                } else {
                    Text("Quản lý danh sách hồ sơ học viên.")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            Spacer()

            Button {
                userVM.authService.signOut()
            } label: {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 15))
                    .foregroundStyle(.white)
                    .frame(width: 38, height: 38)
                    .background(Circle().fill(Color.white.opacity(0.08)))
            }
        }
    }

    // MARK: - Empty Profile Card
    private var emptyProfileCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 40))
                .foregroundStyle(LiquidGlassTheme.primaryAccent)

            Text("Chưa có hồ sơ học tập nào trên tài khoản này.")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)

            Text("Hãy tạo một hồ sơ mới để lưu trữ điểm thi và theo dõi lộ trình.")
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.65))
                .multilineTextAlignment(.center)

            LiquidGlassButton(title: "Tạo Hồ Sơ Đầu Tiên", icon: "plus") {
                showAddUserSheet = true
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .liquidGlassCard(cornerRadius: 22, padding: 22)
    }

    // MARK: - Active Profile Card
    private func activeProfileCard(user: UserModel) -> some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                // Large Avatar
                ZStack {
                    Circle()
                        .fill(LiquidGlassTheme.primaryButtonGradient)
                        .frame(width: 64, height: 64)
                        .overlay(Circle().stroke(Color.white.opacity(0.35), lineWidth: 1.5))
                        .shadow(color: LiquidGlassTheme.primaryAccent.opacity(0.4), radius: 10)

                    Text(String(user.name.prefix(1)))
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(user.name)
                            .font(.system(size: 19, weight: .bold))
                            .foregroundStyle(.white)

                        Text("Đang chọn")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(LiquidGlassTheme.scoreTotal)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(LiquidGlassTheme.scoreTotal.opacity(0.18)))
                    }

                    Text("Ngày sinh: \(user.dateOfBirth, format: .dateTime.day().month().year())")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.6))

                    Text("Mục tiêu: \(user.targetScore) điểm \(user.isFourSkills ? "(4 kỹ năng)" : "(2 kỹ năng)")")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(LiquidGlassTheme.scoreListening)
                }

                Spacer()

                Button {
                    userToEdit = user
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(Color.white.opacity(0.1)))
                }
            }

            // Streak & stats row
            HStack(spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(LiquidGlassTheme.streakFire)
                    Text("\(user.currentStreak) ngày streak")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(RoundedRectangle(cornerRadius: 12).fill(LiquidGlassTheme.streakFire.opacity(0.12)))

                HStack(spacing: 6) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .foregroundStyle(LiquidGlassTheme.scoreTotal)
                    Text("\(user.scores.count) bài đã thi")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(RoundedRectangle(cornerRadius: 12).fill(LiquidGlassTheme.scoreTotal.opacity(0.12)))
            }
        }
        .liquidGlassCard(cornerRadius: 22, padding: 18)
    }

    // MARK: - Profiles Section
    private var profilesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Danh Sách Hồ Sơ")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)

                Spacer()

                Button {
                    showAddUserSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text("Thêm mới")
                    }
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(LiquidGlassTheme.primaryAccent)
                }
            }

            ForEach(userVM.users) { user in
                let isSelected = user.id == userVM.currentUserId

                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(isSelected ? LiquidGlassTheme.primaryButtonGradient : LinearGradient(colors: [Color.white.opacity(0.15)], startPoint: .top, endPoint: .bottom))
                            .frame(width: 40, height: 40)

                        Text(String(user.name.prefix(1)))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(user.name)
                            .font(.system(size: 14, weight: isSelected ? .bold : .medium))
                            .foregroundStyle(.white)

                        Text("Mục tiêu: \(user.targetScore)đ • \(user.scores.count) bài thi")
                            .font(.system(size: 11))
                            .foregroundStyle(.white.opacity(0.6))
                    }

                    Spacer()

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(LiquidGlassTheme.scoreTotal)
                    } else {
                        Button("Chọn") {
                            userVM.switchUser(to: user.id)
                        }
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color.white.opacity(0.1)))
                    }

                    if userVM.users.count > 1 {
                        Button {
                            userVM.deleteUser(id: user.id)
                        } label: {
                            Image(systemName: "trash")
                                .font(.system(size: 12))
                                .foregroundStyle(.white.opacity(0.35))
                                .padding(6)
                        }
                    }
                }
                .liquidGlassCard(cornerRadius: 16, padding: 12)
            }
        }
    }

    // MARK: - Utilities Section
    private var utilitiesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Cài Đặt Học Tập")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)

            Button {
                userVM.toggleFourSkills()
            } label: {
                HStack {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundStyle(LiquidGlassTheme.purpleAccent)
                    Text("Chế độ 4 kỹ năng (Nghe, Đọc, Nói, Viết)")
                        .font(.system(size: 14))
                        .foregroundStyle(.white)
                    Spacer()
                    Image(systemName: (currentUser?.isFourSkills ?? false) ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle((currentUser?.isFourSkills ?? false) ? LiquidGlassTheme.scoreTotal : .white.opacity(0.4))
                }
                .padding(.vertical, 4)
            }
            .liquidGlassCard(cornerRadius: 16, padding: 14)
        }
    }

    // MARK: - Account Section
    private var accountSection: some View {
        VStack(spacing: 8) {
            Text("☁️ Đồng bộ Cloud Firestore: toeic-tracker-52828")
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.6))

            Text("Phiên bản 1.0.0 (Native SwiftUI • Realtime Firebase)")
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 10)
    }
}
