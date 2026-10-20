import SwiftUI

public struct HomeView: View {
    @ObservedObject public var userVM: UserViewModel
    @State private var showAddScoreSheet: Bool = false
    @State private var showLearningPathSheet: Bool = false
    @State private var scoreToEdit: ToeicScore?

    private var currentUser: UserModel? {
        userVM.currentUser
    }

    private var isFourSkills: Bool {
        currentUser?.isFourSkills ?? false
    }

    private var targetScore: Int {
        currentUser?.targetScore ?? 500
    }

    private var latestTotal: Int {
        currentUser?.latestScore?.calculateTotal(isFourSkills: isFourSkills) ?? 0
    }

    private var gapToTarget: Int {
        max(targetScore - latestTotal, 0)
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Top Header: User Profile & Streak
                headerSection

                // Target Score Hero Card
                targetHeroCard

                // Interactive Chart
                if let scores = currentUser?.scores {
                    ScoreChartView(
                        scores: scores,
                        targetScore: targetScore,
                        isFourSkills: isFourSkills
                    )
                }

                // 4 Quick Stat Tiles
                quickStatsGrid

                // Quick Action Bar
                quickActionsBar

                // Recent Scores History List
                recentScoresSection

                // Bottom spacer for floating tab bar
                Spacer().frame(height: 100)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
        .liquidGlassBackground()
        .sheet(isPresented: $showAddScoreSheet) {
            AddScoreSheet(userVM: userVM, existingScore: nil)
        }
        .sheet(item: $scoreToEdit) { score in
            AddScoreSheet(userVM: userVM, existingScore: score)
        }
        .sheet(isPresented: $showLearningPathSheet) {
            LearningPathView(userVM: userVM)
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack(alignment: .center, spacing: 14) {
            // User Avatar
            ZStack {
                Circle()
                    .fill(LiquidGlassTheme.primaryButtonGradient)
                    .frame(width: 48, height: 48)
                    .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 1.2))

                Text(String(currentUser?.name.prefix(1) ?? "H"))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(currentUser?.name ?? "Học viên")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)

                Text("Mục tiêu: \(targetScore) điểm \(isFourSkills ? "(4 kỹ năng)" : "")")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.65))
            }

            Spacer()

            // Streak Fire Badge
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 15))
                    .foregroundStyle(LiquidGlassTheme.streakFire)

                Text("\(currentUser?.currentStreak ?? 0) ngày")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background {
                Capsule()
                    .fill(LiquidGlassTheme.streakFire.opacity(0.18))
            }
            .overlay {
                Capsule()
                    .strokeBorder(LiquidGlassTheme.streakFire.opacity(0.4), lineWidth: 1.0)
            }
        }
        .liquidGlassCard(cornerRadius: 20, padding: 14)
    }

    // MARK: - Target Hero Card
    private var targetHeroCard: some View {
        HStack(spacing: 18) {
            CircularScoreGaugeView(
                currentScore: latestTotal,
                targetScore: targetScore,
                size: 110,
                strokeWidth: 10
            )

            VStack(alignment: .leading, spacing: 8) {
                Text("Mục tiêu của bạn")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.6))

                if gapToTarget == 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(LiquidGlassTheme.amberAccent)
                        Text("ĐÃ ĐẠT MỤC TIÊU!")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(LiquidGlassTheme.scoreTotal)
                    }
                    Text("Tuyệt vời! Bạn đã vượt qua mốc \(targetScore) điểm. Hãy nâng cao mục tiêu để bứt phá hơn nữa!")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.75))
                } else {
                    HStack(spacing: 4) {
                        Text("Còn thiếu")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.white.opacity(0.85))

                        Text("+\(gapToTarget)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(LiquidGlassTheme.amberAccent)

                        Text("điểm")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.white.opacity(0.85))
                    }

                    Text("Học đều đặn mỗi ngày và làm đề thi ETS 2026 sẽ giúp bạn về đích nhanh chóng!")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.65))
                }
            }

            Spacer()
        }
        .liquidGlassCard(cornerRadius: 24, padding: 18)
    }

    // MARK: - Quick Stats Grid
    private var quickStatsGrid: some View {
        let highest = currentUser?.highestScore?.calculateTotal(isFourSkills: isFourSkills) ?? 0
        let latest = latestTotal
        let avg = currentUser?.averageScore ?? 0
        let count = currentUser?.scores.count ?? 0

        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            statTile(title: "Điểm cao nhất", value: "\(highest)", icon: "crown.fill", color: LiquidGlassTheme.amberAccent)
            statTile(title: "Điểm gần nhất", value: "\(latest)", icon: "clock.arrow.circlepath", color: LiquidGlassTheme.scoreListening)
            statTile(title: "Điểm trung bình", value: "\(avg)", icon: "chart.bar.fill", color: LiquidGlassTheme.purpleAccent)
            statTile(title: "Số bài thi đã lưu", value: "\(count)", icon: "doc.text.fill", color: LiquidGlassTheme.scoreTotal)
        }
    }

    private func statTile(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(color)
                Spacer()
            }

            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.white.opacity(0.6))
        }
        .liquidGlassCard(cornerRadius: 18, padding: 14)
    }

    // MARK: - Quick Actions Bar
    private var quickActionsBar: some View {
        HStack(spacing: 10) {
            LiquidGlassButton(title: "Thêm Điểm", icon: "plus.circle.fill") {
                showAddScoreSheet = true
            }

            Button {
                showLearningPathSheet = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "map.fill")
                    Text("Lộ Trình")
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.08)))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.2), lineWidth: 1))
            }
            .buttonStyle(ScaleButtonStyle())

            Button {
                userVM.toggleFourSkills()
            } label: {
                Image(systemName: isFourSkills ? "4.circle.fill" : "2.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(isFourSkills ? LiquidGlassTheme.purpleAccent : .white.opacity(0.7))
                    .padding(11)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.08)))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.2), lineWidth: 1))
            }
            .buttonStyle(ScaleButtonStyle())
        }
    }

    // MARK: - Recent Scores
    private var recentScoresSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Lịch Sử Bài Thi")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)

                Spacer()

                if let count = currentUser?.scores.count, count > 0 {
                    Text("\(count) bài")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.55))
                }
            }

            let sorted = currentUser?.scores.sorted(by: { $0.date > $1.date }) ?? []
            if sorted.isEmpty {
                VStack(spacing: 8) {
                    Text("Chưa có điểm bài thi nào. Nhấn \"Thêm Điểm\" để bắt đầu theo dõi!")
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 24)
                }
                .frame(maxWidth: .infinity)
                .liquidGlassCard(cornerRadius: 18, padding: 14)
            } else {
                ForEach(sorted) { score in
                    ScoreCardView(
                        score: score,
                        targetScore: targetScore,
                        isFourSkills: isFourSkills,
                        onEdit: { scoreToEdit = score },
                        onDelete: { userVM.deleteScore(id: score.id) }
                    )
                }
            }
        }
    }
}
