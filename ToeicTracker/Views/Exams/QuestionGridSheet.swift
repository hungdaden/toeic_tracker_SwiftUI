import SwiftUI

public struct QuestionGridSheet: View {
    @ObservedObject public var examVM: ExamViewModel
    @Environment(\.dismiss) private var dismiss

    private var groupedQuestions: [(QuestionPart, [ToeicQuestion])] {
        guard let exam = examVM.selectedExam else { return [] }
        return QuestionPart.allCases.compactMap { part in
            let qInPart = exam.questions.filter { $0.part == part }
            return qInPart.isEmpty ? nil : (part, qInPart)
        }
    }

    public var body: some View {
        VStack(spacing: 16) {
            // Drag handle and Title
            VStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 40, height: 5)
                    .padding(.top, 8)

                HStack {
                    Text("Danh Sách Câu Hỏi (200 câu)")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)

                    Spacer()

                    // Legend
                    HStack(spacing: 12) {
                        legendItem(color: LiquidGlassTheme.scoreTotal, label: "Đã chọn")
                        legendItem(color: LiquidGlassTheme.secondaryAccent, label: "Đang xem")
                        legendItem(color: Color.white.opacity(0.2), label: "Chưa làm")
                    }
                }
                .padding(.horizontal, 20)
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(groupedQuestions, id: \.0) { part, questions in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(part.displayName)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(part.isListening ? LiquidGlassTheme.scoreListening : LiquidGlassTheme.scoreReading)
                                .padding(.horizontal, 4)

                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6), spacing: 8) {
                                ForEach(questions) { q in
                                    let isCurrent = examVM.currentQuestion?.number == q.number
                                    let isAnswered = examVM.userAnswers[q.number] != nil

                                    Button {
                                        dismiss()
                                        if let idx = examVM.selectedExam?.questions.firstIndex(where: { $0.number == q.number }) {
                                            examVM.goToQuestion(index: idx)
                                        }
                                    } label: {
                                        Text("\(q.number)")
                                            .font(.system(size: 13, weight: isCurrent ? .bold : .medium, design: .rounded))
                                            .foregroundStyle(isCurrent || isAnswered ? .white : .white.opacity(0.6))
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 38)
                                            .background {
                                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                    .fill(
                                                        isCurrent ? LiquidGlassTheme.secondaryAccent.opacity(0.8) :
                                                        isAnswered ? LiquidGlassTheme.scoreTotal.opacity(0.6) :
                                                        Color.white.opacity(0.08)
                                                    )
                                            }
                                            .overlay {
                                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                    .strokeBorder(
                                                        isCurrent ? Color.white :
                                                        isAnswered ? LiquidGlassTheme.scoreTotal :
                                                        Color.white.opacity(0.12),
                                                        lineWidth: isCurrent ? 1.5 : 1.0
                                                    )
                                            }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .liquidGlassCard(cornerRadius: 16, padding: 12)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
        }
        .background(Color(hex: 0x090D16).ignoresSafeArea())
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
        }
    }
}
