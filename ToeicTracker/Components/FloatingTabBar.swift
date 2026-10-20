import SwiftUI

public enum AppTab: Int, CaseIterable, Identifiable {
    case home = 0
    case exams = 1
    case munAI = 2
    case leaderboard = 3
    case profile = 4

    public var id: Int { rawValue }

    public var title: String {
        switch self {
        case .home: return "Trang chủ"
        case .exams: return "Bài thi"
        case .munAI: return "Mun AI"
        case .leaderboard: return "Bảng vàng"
        case .profile: return "Hồ sơ"
        }
    }

    public var iconName: String {
        switch self {
        case .home: return "house.fill"
        case .exams: return "doc.text.fill"
        case .munAI: return "sparkles"
        case .leaderboard: return "trophy.fill"
        case .profile: return "person.crop.circle.fill"
        }
    }

    public var activeGradient: LinearGradient {
        switch self {
        case .home: return LiquidGlassTheme.primaryButtonGradient
        case .exams: return LiquidGlassTheme.cyanBlueGradient
        case .munAI: return LiquidGlassTheme.purpleGradient
        case .leaderboard: return LiquidGlassTheme.amberGoldGradient
        case .profile: return LiquidGlassTheme.emeraldGradient
        }
    }
}

public struct FloatingTabBar: View {
    @Binding public var selectedTab: AppTab

    public init(selectedTab: Binding<AppTab>) {
        self._selectedTab = selectedTab
    }

    public var body: some View {
        HStack(spacing: 4) {
            ForEach(AppTab.allCases) { tab in
                let isSelected = selectedTab == tab
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 4) {
                        ZStack {
                            if isSelected {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(tab.activeGradient)
                                    .frame(width: 44, height: 32)
                                    .shadow(color: Color.white.opacity(0.18), radius: 8, x: 0, y: 2)
                            }

                            Image(systemName: tab.iconName)
                                .font(.system(size: isSelected ? 17 : 16, weight: isSelected ? .bold : .medium))
                                .foregroundStyle(isSelected ? .white : .white.opacity(0.55))
                        }
                        .frame(height: 32)

                        Text(tab.title)
                            .font(.system(size: 10, weight: isSelected ? .bold : .medium))
                            .foregroundStyle(isSelected ? .white : .white.opacity(0.55))
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(LiquidGlassTheme.crystalGlassGradient)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(LiquidGlassTheme.crystalGlassBorder, lineWidth: 1.2)
        }
        .shadow(color: Color.black.opacity(0.45), radius: 24, x: 0, y: 10)
        .shadow(color: LiquidGlassTheme.primaryAccent.opacity(0.15), radius: 16, x: 0, y: 4)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}
