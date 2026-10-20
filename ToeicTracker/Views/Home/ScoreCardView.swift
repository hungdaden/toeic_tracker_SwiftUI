import SwiftUI

public struct ScoreCardView: View {
    public let score: ToeicScore
    public let targetScore: Int
    public let isFourSkills: Bool
    public var onEdit: (() -> Void)?
    public var onDelete: (() -> Void)?

    private var total: Int {
        score.calculateTotal(isFourSkills: isFourSkills)
    }

    private var isHitTarget: Bool {
        total >= targetScore
    }

    public var body: some View {
        HStack(alignment: .center, spacing: 14) {
            // Total score badge
            VStack(spacing: 2) {
                Text("\(total)")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(isHitTarget ? LiquidGlassTheme.scoreTotal : .white)

                Text("Tổng điểm")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.white.opacity(0.55))
            }
            .frame(width: 72, height: 60)
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isHitTarget ? LiquidGlassTheme.scoreTotal.opacity(0.15) : Color.white.opacity(0.06))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(isHitTarget ? LiquidGlassTheme.scoreTotal.opacity(0.4) : Color.white.opacity(0.12), lineWidth: 1.0)
            }

            // Breakdown
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(score.date, format: .dateTime.day().month().year())
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)

                    if isHitTarget {
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 9))
                            Text("Đạt mục tiêu")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundStyle(LiquidGlassTheme.amberAccent)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(LiquidGlassTheme.amberAccent.opacity(0.18)))
                    }
                }

                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "headphones")
                            .font(.system(size: 11))
                            .foregroundStyle(LiquidGlassTheme.scoreListening)
                        Text("Nghe: \(score.listeningScore)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(LiquidGlassTheme.scoreListening)
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(LiquidGlassTheme.scoreReading)
                        Text("Đọc: \(score.readingScore)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(LiquidGlassTheme.scoreReading)
                    }

                    if isFourSkills {
                        if let sp = score.speakingScore {
                            Text("Nói: \(sp)")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(LiquidGlassTheme.scoreSpeaking)
                        }
                        if let wr = score.writingScore {
                            Text("Viết: \(wr)")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(LiquidGlassTheme.scoreWriting)
                        }
                    }
                }
            }

            Spacer()

            // Action menu
            Menu {
                if let onEdit {
                    Button(action: onEdit) {
                        Label("Chỉnh sửa", systemImage: "pencil")
                    }
                }
                if let onDelete {
                    Button(role: .destructive, action: onDelete) {
                        Label("Xóa", systemImage: "trash")
                    }
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(8)
                    .contentShape(Rectangle())
            }
        }
        .liquidGlassCard(cornerRadius: 18, padding: 14)
    }
}
