import SwiftUI

public struct ExamResultSheet: View {
    public let result: ExamResult
    public let exam: ToeicExam
    @ObservedObject public var userVM: UserViewModel
    public var onDismiss: () -> Void

    @State private var hasSavedScore: Bool = false

    private var targetScore: Int {
        userVM.currentUser?.targetScore ?? 750
    }

    private var isHitAim: Bool {
        result.totalScore >= targetScore
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                // Header
                VStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 40, height: 5)
                        .padding(.top, 8)

                    Text("Kết Quả Bài Thi")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)

                    Text(result.examTitle)
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.6))
                }

                // Total Score Hero
                VStack(spacing: 10) {
                    if isHitAim {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                            Text("CHÚC MỪNG BẠN ĐẠT MỤC TIÊU!")
                            Image(systemName: "sparkles")
                        }
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(LiquidGlassTheme.amberAccent)
                    }

                    Text("\(result.totalScore)")
                        .font(.system(size: 58, weight: .bold, design: .rounded))
                        .foregroundStyle(isHitAim ? LiquidGlassTheme.scoreTotal : .white)
                        .shadow(color: isHitAim ? LiquidGlassTheme.scoreTotal.opacity(0.5) : Color.clear, radius: 16)

                    Text("thang điểm ETS chuẩn (10 - 990)")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.55))
                }
                .frame(maxWidth: .infinity)
                .liquidGlassCard(cornerRadius: 24, padding: 20)

                // Listening & Reading Breakdown
                HStack(spacing: 12) {
                    scoreSectionTile(
                        title: "Nghe (Listening)",
                        score: result.listeningScore,
                        correctCount: result.correctListening,
                        icon: "headphones",
                        color: LiquidGlassTheme.scoreListening
                    )

                    scoreSectionTile(
                        title: "Đọc (Reading)",
                        score: result.readingScore,
                        correctCount: result.correctReading,
                        icon: "book.fill",
                        color: LiquidGlassTheme.scoreReading
                    )
                }

                // Part-by-Part Details
                VStack(alignment: .leading, spacing: 12) {
                    Text("Chi Tiết Từng Phần (Part 1 - 7)")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)

                    ForEach(QuestionPart.allCases) { part in
                        let partQuestions = exam.questions.filter { $0.part == part }
                        if !partQuestions.isEmpty {
                            let correct = partQuestions.filter { q in
                                result.userAnswers[q.number] == q.correctOptionIndex
                            }.count
                            let total = partQuestions.count
                            let pct = Double(correct) / Double(total)

                            VStack(spacing: 6) {
                                HStack {
                                    Text(part.displayName)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(.white)

                                    Spacer()

                                    Text("\(correct)/\(total) câu (\(Int(pct * 100))%)")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(part.isListening ? LiquidGlassTheme.scoreListening : LiquidGlassTheme.scoreReading)
                                }

                                GeometryReader { proxy in
                                    ZStack(alignment: .leading) {
                                        Capsule()
                                            .fill(Color.white.opacity(0.08))
                                            .frame(height: 6)

                                        Capsule()
                                            .fill(part.isListening ? LiquidGlassTheme.scoreListening : LiquidGlassTheme.scoreReading)
                                            .frame(width: proxy.size.width * CGFloat(pct), height: 6)
                                    }
                                }
                                .frame(height: 6)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .liquidGlassCard(cornerRadius: 20, padding: 18)

                // Save Score Button
                VStack(spacing: 10) {
                    if !hasSavedScore {
                        LiquidGlassButton(title: "Lưu Kết Quả Vào Hồ Sơ", icon: "square.and.arrow.down.fill") {
                            let newScore = ToeicScore(
                                date: result.timestamp,
                                listeningScore: result.listeningScore,
                                readingScore: result.readingScore
                            )
                            _ = userVM.addScore(newScore)
                            hasSavedScore = true
                        }
                    } else {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(LiquidGlassTheme.scoreTotal)
                            Text("Đã lưu vào hồ sơ học tập")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        .padding(.vertical, 12)
                    }

                    Button("Đóng và Trở Về") {
                        onDismiss()
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.7))
                    .padding(.top, 4)
                }

                Spacer().frame(height: 30)
            }
            .padding(.horizontal, 20)
        }
        .background(Color(hex: 0x090D16).ignoresSafeArea())
    }

    private func scoreSectionTile(title: String, score: Int, correctCount: Int, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.system(size: 14))
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.8))
            }

            Text("\(score)")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(color)

            Text("\(correctCount) / 100 câu đúng")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .liquidGlassCard(cornerRadius: 18, padding: 14)
    }
}
