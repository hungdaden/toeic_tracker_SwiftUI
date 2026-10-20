import SwiftUI

public struct ExamListView: View {
    @ObservedObject public var examVM: ExamViewModel
    @ObservedObject public var userVM: UserViewModel

    @State private var selectedExamForMode: ToeicExam?
    @State private var activeExamSession: ToeicExam?

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 6) {
                    Text("Bộ Đề Thi ETS 2026")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)

                    Text("Luyện đề chính thức ETS 2026 với cấu trúc 200 câu hỏi, audio giọng chuẩn và đồng hồ thi thực tế.")
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.65))
                }
                .padding(.top, 10)

                // Exam Cards List
                ForEach(examVM.availableExams) { exam in
                    examCard(exam: exam)
                }

                Spacer().frame(height: 100)
            }
            .padding(.horizontal, 16)
        }
        .liquidGlassBackground()
        .sheet(item: $selectedExamForMode) { exam in
            ExamModeModal(exam: exam) { isExamMode in
                examVM.startExam(exam: exam, isExamMode: isExamMode)
                activeExamSession = exam
            }
        }
        .fullScreenCover(item: $activeExamSession) { exam in
            ExamSessionView(examVM: examVM, userVM: userVM)
        }
    }

    private func examCard(exam: ToeicExam) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(LiquidGlassTheme.primaryAccent.opacity(0.18))
                        .frame(width: 48, height: 48)

                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(LiquidGlassTheme.primaryAccent)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(exam.title)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)

                        if let tag = exam.tag {
                            Text(tag)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(LiquidGlassTheme.scoreListening)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(LiquidGlassTheme.scoreListening.opacity(0.18)))
                        }
                    }

                    Text(exam.description ?? "")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.65))
                        .lineLimit(2)
                }

                Spacer()
            }

            // Badges
            HStack(spacing: 8) {
                badgeChip(icon: "list.number", text: "200 câu hỏi")
                badgeChip(icon: "clock.fill", text: "\(exam.timeLimitMinutes) phút")
                badgeChip(icon: "waveform", text: "Part 1 - 7")
            }

            // Start Button
            Button {
                selectedExamForMode = exam
            } label: {
                HStack {
                    Spacer()
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 16, weight: .bold))
                    Text("Bắt Đầu Làm Bài")
                        .font(.system(size: 14, weight: .bold))
                    Spacer()
                }
                .foregroundStyle(.white)
                .padding(.vertical, 12)
                .background(RoundedRectangle(cornerRadius: 14).fill(LiquidGlassTheme.primaryButtonGradient))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.3), lineWidth: 1))
                .shadow(color: LiquidGlassTheme.primaryAccent.opacity(0.35), radius: 10, x: 0, y: 4)
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .liquidGlassCard(cornerRadius: 22, padding: 18)
    }

    private func badgeChip(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.6))
            Text(text)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.white.opacity(0.75))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Capsule().fill(Color.white.opacity(0.06)))
    }
}
