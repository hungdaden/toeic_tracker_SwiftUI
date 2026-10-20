import SwiftUI

public struct LeaderboardEntry: Identifiable {
    public var id: String { "\(user.id)_\(score.id)" }
    public let user: UserModel
    public let score: ToeicScore
    public var total: Int { score.calculateTotal(isFourSkills: user.isFourSkills) }
}

public struct LeaderboardView: View {
    @ObservedObject public var userVM: UserViewModel
    @State private var isGroupMode: Bool = false
    @State private var showGroupDialog: Bool = false

    private var rankedEntries: [LeaderboardEntry] {
        var entries: [LeaderboardEntry] = []
        for user in userVM.users {
            for score in user.scores {
                entries.append(LeaderboardEntry(user: user, score: score))
            }
        }
        return entries.sorted(by: { $0.total > $1.total })
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header with title and group action
                headerBar

                // Mode switch: Cá nhân vs Nhóm
                modeSelector

                if rankedEntries.isEmpty {
                    emptyState
                } else {
                    // Podium (Top 3)
                    podiumSection

                    // Ranking List (Rank 4+)
                    rankingListSection
                }

                Spacer().frame(height: 100)
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
        }
        .liquidGlassBackground()
        .sheet(isPresented: $showGroupDialog) {
            GroupDialogView(userVM: userVM)
        }
    }

    // MARK: - Header Bar
    private var headerBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(isGroupMode ? "Bảng Vàng Nhóm" : "Bảng Vàng Thành Tích")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)

                Text("Vinh danh những điểm số cao nhất và chuỗi rèn luyện bền bỉ.")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.6))
            }

            Spacer()

            Button {
                showGroupDialog = true
            } label: {
                Image(systemName: "person.3.sequence.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(Circle().fill(LiquidGlassTheme.amberGoldGradient))
                    .shadow(color: LiquidGlassTheme.amberAccent.opacity(0.35), radius: 8)
            }
        }
    }

    // MARK: - Mode Selector
    private var modeSelector: some View {
        HStack(spacing: 4) {
            modeButton(title: "Cá Nhân", isSelected: !isGroupMode) {
                withAnimation { isGroupMode = false }
            }
            modeButton(title: "Nhóm Học Tập", isSelected: isGroupMode) {
                withAnimation { isGroupMode = true }
            }
        }
        .padding(4)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.08)))
    }

    private func modeButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                .foregroundStyle(isSelected ? .white : .white.opacity(0.6))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12).fill(LiquidGlassTheme.primaryButtonGradient)
                    }
                }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Podium Section (Top 3)
    private var podiumSection: some View {
        let top3 = Array(rankedEntries.prefix(3))

        return HStack(alignment: .bottom, spacing: 12) {
            // Rank 2 (Silver)
            if top3.count > 1 {
                podiumItem(
                    entry: top3[1],
                    rank: 2,
                    podiumHeight: 110,
                    color: Color(hex: 0x94A3B8),
                    gradient: LinearGradient(colors: [Color(hex: 0xCBD5E1), Color(hex: 0x64748B)], startPoint: .top, endPoint: .bottom)
                )
            }

            // Rank 1 (Gold)
            if let first = top3.first {
                podiumItem(
                    entry: first,
                    rank: 1,
                    podiumHeight: 140,
                    color: LiquidGlassTheme.amberAccent,
                    gradient: LiquidGlassTheme.amberGoldGradient,
                    isFirst: true
                )
            }

            // Rank 3 (Bronze)
            if top3.count > 2 {
                podiumItem(
                    entry: top3[2],
                    rank: 3,
                    podiumHeight: 90,
                    color: Color(hex: 0xCD7F32),
                    gradient: LinearGradient(colors: [Color(hex: 0xD97706), Color(hex: 0x78350F)], startPoint: .top, endPoint: .bottom)
                )
            }
        }
        .padding(.vertical, 14)
    }

    private func podiumItem(
        entry: LeaderboardEntry,
        rank: Int,
        podiumHeight: CGFloat,
        color: Color,
        gradient: LinearGradient,
        isFirst: Bool = false
    ) -> some View {
        VStack(spacing: 6) {
            // Crown or Medal Icon
            if isFirst {
                Image(systemName: "crown.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(LiquidGlassTheme.amberAccent)
                    .shadow(color: LiquidGlassTheme.amberAccent, radius: 8)
            }

            // Avatar
            ZStack {
                Circle()
                    .fill(gradient)
                    .frame(width: isFirst ? 58 : 48, height: isFirst ? 58 : 48)
                    .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 1.5))
                    .shadow(color: color.opacity(0.4), radius: 10)

                Text(String(entry.user.name.prefix(1)))
                    .font(.system(size: isFirst ? 22 : 18, weight: .bold))
                    .foregroundStyle(.white)
            }

            // Name
            Text(entry.user.name)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(1)

            // Score Pill
            Text("\(entry.total)")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(color)

            // Podium Stand
            VStack {
                Text("\(rank)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.top, 10)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: podiumHeight)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.08))
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(color.opacity(0.35), lineWidth: 1)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Ranking List (Rank 4+)
    private var rankingListSection: some View {
        let rest = rankedEntries.dropFirst(3)

        return VStack(alignment: .leading, spacing: 10) {
            if !rest.isEmpty {
                Text("Bảng Xếp Hạng Tiếp Theo")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.top, 6)

                ForEach(Array(rest.enumerated()), id: \.element.id) { index, entry in
                    let rank = index + 4
                    HStack(spacing: 12) {
                        Text("\(rank)")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.6))
                            .frame(width: 24)

                        ZStack {
                            Circle()
                                .fill(LiquidGlassTheme.primaryAccent.opacity(0.25))
                                .frame(width: 38, height: 38)
                            Text(String(entry.user.name.prefix(1)))
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(.white)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(entry.user.name)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.white)

                            HStack(spacing: 8) {
                                Text("L: \(entry.score.listeningScore)")
                                    .font(.system(size: 11))
                                    .foregroundStyle(LiquidGlassTheme.scoreListening)
                                Text("R: \(entry.score.readingScore)")
                                    .font(.system(size: 11))
                                    .foregroundStyle(LiquidGlassTheme.scoreReading)
                            }
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(entry.total)")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundStyle(LiquidGlassTheme.scoreTotal)

                            HStack(spacing: 2) {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 10))
                                    .foregroundStyle(LiquidGlassTheme.streakFire)
                                Text("\(entry.user.currentStreak) ngày")
                                    .font(.system(size: 10))
                                    .foregroundStyle(.white.opacity(0.6))
                            }
                        }
                    }
                    .liquidGlassCard(cornerRadius: 16, padding: 12)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "trophy")
                .font(.system(size: 44))
                .foregroundStyle(.white.opacity(0.3))
            Text("Chưa có thành tích thi nào được ghi nhận.")
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .liquidGlassCard(cornerRadius: 20, padding: 24)
    }
}
