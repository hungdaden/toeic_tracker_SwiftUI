import SwiftUI

public struct AddScoreSheet: View {
    @ObservedObject public var userVM: UserViewModel
    public var existingScore: ToeicScore?
    @Environment(\.dismiss) private var dismiss

    @State private var listeningScore: Double = 350
    @State private var readingScore: Double = 300
    @State private var speakingScore: Double = 120
    @State private var writingScore: Double = 120
    @State private var selectedDate: Date = Date()

    private var isFourSkills: Bool {
        userVM.currentUser?.isFourSkills ?? false
    }

    private var targetScore: Int {
        userVM.currentUser?.targetScore ?? 750
    }

    private var currentTotal: Int {
        let l = Int(listeningScore)
        let r = Int(readingScore)
        if isFourSkills {
            return l + r + Int(speakingScore) + Int(writingScore)
        }
        return l + r
    }

    private var isHitTarget: Bool {
        currentTotal >= targetScore
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 40, height: 5)
                        .padding(.top, 8)

                    Text(existingScore != nil ? "Chỉnh Sửa Điểm Thi" : "Ghi Nhận Điểm Thi")
                        .font(.system(size: 19, weight: .bold))
                        .foregroundStyle(.white)

                    Text("Nhập điểm Listening & Reading để cập nhật biểu đồ tiến trình.")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.65))
                }

                // Live Score Preview Hero
                VStack(spacing: 6) {
                    Text("Tổng điểm ước tính")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.6))

                    Text("\(currentTotal)")
                        .font(.system(size: 46, weight: .bold, design: .rounded))
                        .foregroundStyle(isHitTarget ? LiquidGlassTheme.scoreTotal : .white)

                    if isHitTarget {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                            Text("ĐẠT MỤC TIÊU (\(targetScore) điểm) 🎉")
                        }
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(LiquidGlassTheme.amberAccent)
                    } else {
                        Text("Mục tiêu: \(targetScore)đ (còn thiếu +\(max(targetScore - currentTotal, 0))đ)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                .frame(maxWidth: .infinity)
                .liquidGlassCard(cornerRadius: 22, padding: 16)

                // Date Picker
                VStack(alignment: .leading, spacing: 8) {
                    DatePicker("Ngày làm bài thi:", selection: $selectedDate, displayedComponents: .date)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .colorScheme(.dark)
                }
                .liquidGlassCard(cornerRadius: 18, padding: 14)

                // Sliders & Steppers
                VStack(spacing: 16) {
                    // Listening Slider
                    scoreSlider(
                        title: "Nghe (Listening)",
                        score: $listeningScore,
                        maxScore: 495,
                        icon: "headphones",
                        color: LiquidGlassTheme.scoreListening
                    )

                    Divider().background(Color.white.opacity(0.1))

                    // Reading Slider
                    scoreSlider(
                        title: "Đọc (Reading)",
                        score: $readingScore,
                        maxScore: 495,
                        icon: "book.fill",
                        color: LiquidGlassTheme.scoreReading
                    )

                    if isFourSkills {
                        Divider().background(Color.white.opacity(0.1))

                        scoreSlider(
                            title: "Nói (Speaking)",
                            score: $speakingScore,
                            maxScore: 200,
                            icon: "mic.fill",
                            color: LiquidGlassTheme.scoreSpeaking
                        )

                        Divider().background(Color.white.opacity(0.1))

                        scoreSlider(
                            title: "Viết (Writing)",
                            score: $writingScore,
                            maxScore: 200,
                            icon: "pencil.and.outline",
                            color: LiquidGlassTheme.scoreWriting
                        )
                    }
                }
                .liquidGlassCard(cornerRadius: 22, padding: 18)

                // Save Button
                LiquidGlassButton(
                    title: existingScore != nil ? "Cập Nhật Điểm" : "Lưu Điểm Thi",
                    icon: "checkmark.circle.fill"
                ) {
                    let score = ToeicScore(
                        id: existingScore?.id ?? UUID().uuidString,
                        date: selectedDate,
                        listeningScore: Int(listeningScore),
                        readingScore: Int(readingScore),
                        speakingScore: isFourSkills ? Int(speakingScore) : nil,
                        writingScore: isFourSkills ? Int(writingScore) : nil
                    )

                    if existingScore != nil {
                        userVM.updateScore(score)
                    } else {
                        _ = userVM.addScore(score)
                    }

                    dismiss()
                }

                Spacer().frame(height: 20)
            }
            .padding(.horizontal, 20)
        }
        .background(Color(hex: 0x090D16).ignoresSafeArea())
        .onAppear {
            if let ex = existingScore {
                listeningScore = Double(ex.listeningScore)
                readingScore = Double(ex.readingScore)
                speakingScore = Double(ex.speakingScore ?? 120)
                writingScore = Double(ex.writingScore ?? 120)
                selectedDate = ex.date
            }
        }
    }

    private func scoreSlider(title: String, score: Binding<Double>, maxScore: Double, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.system(size: 14))

                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)

                Spacer()

                Text("\(Int(score.wrappedValue)) điểm")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(color)
            }

            Slider(value: score, in: 5...maxScore, step: 5)
                .tint(color)
        }
    }
}
