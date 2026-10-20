import SwiftUI

public struct ExamSessionView: View {
    @ObservedObject public var examVM: ExamViewModel
    @ObservedObject public var userVM: UserViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showConfirmSubmitAlert: Bool = false

    private var question: ToeicQuestion? {
        examVM.currentQuestion
    }

    public var body: some View {
        ZStack {
            LiquidGlassTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Custom App Bar
                topSessionBar

                // Audio Player Control (if audio exists)
                if let q = question, q.audioUrl != nil {
                    audioPlayerCard
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                }

                // Scrollable Question Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        if let q = question {
                            // Part & Question number chips
                            HStack {
                                LiquidGlassChipView(
                                    label: q.part.displayName,
                                    accentColor: q.part.isListening ? LiquidGlassTheme.scoreListening : LiquidGlassTheme.scoreReading
                                )

                                Spacer()

                                Text("Câu \(q.number) / \(examVM.selectedExam?.questions.count ?? 200)")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.85))
                            }

                            // Image display (Part 1 photos, Part 3/4 graphics, Part 6/7 passages)
                            if let imageUrl = examVM.resolveImageUrl(for: q) {
                                if let uiImage = UIImage(contentsOfFile: imageUrl.path) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxHeight: 280)
                                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.18), lineWidth: 1))
                                        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 4)
                                }
                            }

                            // Passage text (Part 6 & Part 7)
                            if let passage = q.passage, !passage.isEmpty {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Image(systemName: "doc.text")
                                            .foregroundStyle(LiquidGlassTheme.secondaryAccent)
                                        Text("Đoạn văn đọc hiểu")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundStyle(LiquidGlassTheme.secondaryAccent)
                                    }
                                    Text(passage)
                                        .font(.system(size: 14))
                                        .foregroundStyle(.white.opacity(0.9))
                                        .lineSpacing(4)
                                }
                                .liquidGlassCard(cornerRadius: 16, padding: 14)
                            }

                            // Question Text
                            if let qText = q.questionText, !qText.isEmpty {
                                Text(qText)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.white)
                                    .padding(.vertical, 2)
                            }

                            // Options List (A, B, C, D)
                            VStack(spacing: 10) {
                                ForEach(0..<q.options.count, id: \.self) { optIdx in
                                    optionButton(q: q, optIdx: optIdx)
                                }
                            }

                            // Practice Mode Immediate Explanation & Transcript
                            if !examVM.isExamMode, examVM.userAnswers[q.number] != nil {
                                explanationCard(q: q)
                            }
                        }

                        Spacer().frame(height: 80)
                    }
                    .padding(16)
                }

                // Bottom Session Navigation Bar
                bottomSessionBar
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $examVM.showQuestionGridSheet) {
            QuestionGridSheet(examVM: examVM)
        }
        .sheet(isPresented: $examVM.isCompleted) {
            if let res = examVM.examResult, let ex = examVM.selectedExam {
                ExamResultSheet(result: res, exam: ex, userVM: userVM) {
                    examVM.isCompleted = false
                    dismiss()
                }
            }
        }
        .alert("Nộp bài thi?", isPresented: $showConfirmSubmitAlert) {
            Button("Hủy", role: .cancel) {}
            Button("Nộp bài", role: .destructive) {
                examVM.submitExam()
            }
        } message: {
            let answered = examVM.userAnswers.count
            let total = examVM.selectedExam?.questions.count ?? 200
            Text("Bạn đã hoàn thành \(answered)/\(total) câu hỏi. Bạn có chắc chắn muốn nộp bài để xem điểm chuẩn ETS?")
        }
    }

    // MARK: - Top Session Bar
    private var topSessionBar: some View {
        HStack {
            Button {
                examVM.cleanup()
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Color.white.opacity(0.1)))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(examVM.selectedExam?.title ?? "Đề thi TOEIC")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text(examVM.isExamMode ? "Chế độ Thi thử" : "Chế độ Luyện tập")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(examVM.isExamMode ? LiquidGlassTheme.amberAccent : LiquidGlassTheme.secondaryAccent)
            }

            Spacer()

            if examVM.isExamMode {
                HStack(spacing: 5) {
                    Image(systemName: "timer")
                        .foregroundStyle(LiquidGlassTheme.amberAccent)
                    Text(examVM.formattedTimeRemaining)
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Capsule().fill(LiquidGlassTheme.amberAccent.opacity(0.2)))
                .overlay(Capsule().stroke(LiquidGlassTheme.amberAccent.opacity(0.4), lineWidth: 1))
            }

            Button {
                examVM.showQuestionGridSheet = true
            } label: {
                Image(systemName: "square.grid.3x3.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Color.white.opacity(0.1)))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(hex: 0x0E1424).opacity(0.9))
    }

    // MARK: - Audio Player Card
    private var audioPlayerCard: some View {
        HStack(spacing: 14) {
            Button {
                examVM.audioPlayer.togglePlayPause()
            } label: {
                Image(systemName: examVM.audioPlayer.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(LiquidGlassTheme.primaryButtonGradient))
                    .shadow(color: LiquidGlassTheme.primaryAccent.opacity(0.4), radius: 8)
            }

            VStack(spacing: 4) {
                GeometryReader { proxy in
                    let pct = examVM.audioPlayer.duration > 0 ? examVM.audioPlayer.currentTime / examVM.audioPlayer.duration : 0.0
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.15))
                            .frame(height: 5)

                        Capsule()
                            .fill(LiquidGlassTheme.secondaryAccent)
                            .frame(width: proxy.size.width * CGFloat(pct), height: 5)
                    }
                }
                .frame(height: 6)

                HStack {
                    Text(formatSeconds(examVM.audioPlayer.currentTime))
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.6))
                    Spacer()
                    Text(formatSeconds(examVM.audioPlayer.duration))
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
        }
        .liquidGlassCard(cornerRadius: 18, padding: 12)
    }

    private func formatSeconds(_ sec: TimeInterval) -> String {
        let m = Int(sec) / 60
        let s = Int(sec) % 60
        return String(format: "%02d:%02d", m, s)
    }

    // MARK: - Option Button
    private func optionButton(q: ToeicQuestion, optIdx: Int) -> some View {
        let isSelected = examVM.userAnswers[q.number] == optIdx
        let letters = ["(A)", "(B)", "(C)", "(D)"]
        let letter = optIdx < letters.count ? letters[optIdx] : ""
        let optionText = optIdx < q.options.count ? q.options[optIdx] : ""

        // Practice mode feedback colors
        var bgGradient: LinearGradient?
        var borderClr = Color.white.opacity(0.12)
        var textClr = Color.white

        if !examVM.isExamMode && examVM.userAnswers[q.number] != nil {
            if optIdx == q.correctOptionIndex {
                // Correct answer
                borderClr = LiquidGlassTheme.scoreTotal
                textClr = LiquidGlassTheme.scoreTotal
            } else if isSelected {
                // Wrong answer selected
                borderClr = LiquidGlassTheme.roseAccent
                textClr = LiquidGlassTheme.roseAccent
            }
        } else if isSelected {
            bgGradient = LiquidGlassTheme.primaryButtonGradient
            borderClr = Color.white.opacity(0.5)
        }

        return Button {
            examVM.selectOption(optionIndex: optIdx)
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        } label: {
            HStack(spacing: 12) {
                Text(letter)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(textClr)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(Color.white.opacity(isSelected ? 0.2 : 0.08)))

                Text(optionText)
                    .font(.system(size: 15, weight: isSelected ? .bold : .medium))
                    .foregroundStyle(textClr)
                    .multilineTextAlignment(.leading)

                Spacer()

                if !examVM.isExamMode && examVM.userAnswers[q.number] != nil {
                    if optIdx == q.correctOptionIndex {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(LiquidGlassTheme.scoreTotal)
                            .font(.system(size: 20))
                    } else if isSelected {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(LiquidGlassTheme.roseAccent)
                            .font(.system(size: 20))
                    }
                } else if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.white)
                        .font(.system(size: 14, weight: .bold))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background {
                if let bgGradient {
                    RoundedRectangle(cornerRadius: 16).fill(bgGradient)
                } else {
                    RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.06))
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 16).stroke(borderClr, lineWidth: 1.2)
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Explanation Card
    private func explanationCard(q: ToeicQuestion) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(LiquidGlassTheme.amberAccent)
                Text("Giải thích đáp án")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(LiquidGlassTheme.amberAccent)
            }

            if let explanation = q.explanation {
                Text(explanation)
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.9))
            }

            if let transcript = q.transcript, !transcript.isEmpty {
                Divider().background(Color.white.opacity(0.1))

                HStack {
                    Image(systemName: "text.bubble")
                        .foregroundStyle(LiquidGlassTheme.scoreListening)
                    Text("Audio Transcript:")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(LiquidGlassTheme.scoreListening)
                }

                Text(transcript)
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.85))
            }
        }
        .liquidGlassCard(cornerRadius: 18, padding: 14)
    }

    // MARK: - Bottom Bar
    private var bottomSessionBar: some View {
        HStack(spacing: 12) {
            Button {
                examVM.previousQuestion()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("Trước")
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.08)))
            }
            .disabled(examVM.currentQuestionIndex == 0)
            .opacity(examVM.currentQuestionIndex == 0 ? 0.4 : 1.0)

            Button {
                showConfirmSubmitAlert = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill")
                    Text("Nộp Bài")
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(RoundedRectangle(cornerRadius: 16).fill(LiquidGlassTheme.scoreTotal.opacity(0.85)))
            }

            Button {
                examVM.nextQuestion()
            } label: {
                HStack(spacing: 4) {
                    Text("Sau")
                    Image(systemName: "chevron.right")
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.08)))
            }
            .disabled(examVM.currentQuestionIndex >= (examVM.selectedExam?.questions.count ?? 200) - 1)
            .opacity(examVM.currentQuestionIndex >= (examVM.selectedExam?.questions.count ?? 200) - 1 ? 0.4 : 1.0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(hex: 0x0E1424).opacity(0.95))
    }
}
