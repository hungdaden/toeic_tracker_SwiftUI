import SwiftUI

public struct ExamModeModal: View {
    public let exam: ToeicExam
    public var onSelectMode: (Bool) -> Void
    @Environment(\.dismiss) private var dismiss

    public var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 40, height: 5)
                    .padding(.top, 8)

                Text(exam.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)

                Text("Chọn chế độ làm bài")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.6))
            }

            // Mode 1: Practice Mode
            Button {
                dismiss()
                onSelectMode(false)
            } label: {
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(LiquidGlassTheme.secondaryAccent.opacity(0.18))
                            .frame(width: 52, height: 52)
                        Image(systemName: "book.pages.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(LiquidGlassTheme.secondaryAccent)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Chế độ Luyện tập")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)

                        Text("Không giới hạn thời gian, xem ngay đáp án & lời giải thích chi tiết sau mỗi câu.")
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.65))
                            .lineLimit(2)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.4))
                }
                .liquidGlassCard(cornerRadius: 20, padding: 16)
            }
            .buttonStyle(ScaleButtonStyle())

            // Mode 2: Real Timed Test
            Button {
                dismiss()
                onSelectMode(true)
            } label: {
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(LiquidGlassTheme.primaryAccent.opacity(0.18))
                            .frame(width: 52, height: 52)
                        Image(systemName: "timer")
                            .font(.system(size: 24))
                            .foregroundStyle(LiquidGlassTheme.primaryAccent)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text("Chế độ Thi thử")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white)

                            Text("Chuẩn ETS")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(LiquidGlassTheme.amberAccent)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(LiquidGlassTheme.amberAccent.opacity(0.2)))
                        }

                        Text("Đồng hồ bấm giờ 120 phút, tự động chuyển audio bài nghe, tính điểm và xếp hạng thực tế.")
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.65))
                            .lineLimit(2)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.4))
                }
                .liquidGlassCard(cornerRadius: 20, padding: 16)
            }
            .buttonStyle(ScaleButtonStyle())

            Spacer().frame(height: 10)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
        .background(Color(hex: 0x0E1424).ignoresSafeArea())
        .presentationDetents([.height(340)])
    }
}
