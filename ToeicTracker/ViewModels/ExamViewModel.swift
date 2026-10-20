import Foundation
import SwiftUI
import Combine

public final class ExamViewModel: ObservableObject {
    @Published public var availableExams: [ToeicExam] = []
    @Published public var selectedExam: ToeicExam?
    @Published public var currentQuestionIndex: Int = 0
    @Published public var userAnswers: [Int: Int] = [:] // Question number -> chosen index
    @Published public var isExamMode: Bool = false
    @Published public var secondsRemaining: Int = 120 * 60
    @Published public var isTimerRunning: Bool = false
    @Published public var isCompleted: Bool = false
    @Published public var examResult: ExamResult?
    @Published public var showQuestionGridSheet: Bool = false

    public let audioPlayer = AudioPlayerService.shared
    private let examService = ExamService.shared
    private var timer: Timer?

    public init() {
        self.availableExams = examService.getAvailableExams()
        setupAudioCallbacks()
    }

    private func setupAudioCallbacks() {
        audioPlayer.onPlaybackFinished = { [weak self] in
            guard let self = self, self.isExamMode, !self.isCompleted else { return }
            self.handleAudioFinishedInExamMode()
        }
    }

    public func startExam(exam: ToeicExam, isExamMode: Bool) {
        let fullExam = examService.loadExam(examId: exam.id)
        self.selectedExam = fullExam
        self.isExamMode = isExamMode
        self.currentQuestionIndex = 0
        self.userAnswers = [:]
        self.isCompleted = false
        self.examResult = nil
        self.secondsRemaining = fullExam.timeLimitMinutes * 60

        if isExamMode {
            startTimer()
        } else {
            stopTimer()
        }

        playAudioForCurrentQuestion()
    }

    public var currentQuestion: ToeicQuestion? {
        guard let selectedExam, currentQuestionIndex >= 0, currentQuestionIndex < selectedExam.questions.count else {
            return nil
        }
        return selectedExam.questions[currentQuestionIndex]
    }

    public var currentTestIndex: Int {
        guard let selectedExam else { return 1 }
        if selectedExam.id.contains("test_2") { return 2 }
        return 1
    }

    public func selectOption(optionIndex: Int) {
        guard let q = currentQuestion else { return }
        userAnswers[q.number] = optionIndex
    }

    public func nextQuestion() {
        guard let selectedExam else { return }
        if currentQuestionIndex < selectedExam.questions.count - 1 {
            goToQuestion(index: currentQuestionIndex + 1)
        }
    }

    public func previousQuestion() {
        if currentQuestionIndex > 0 {
            goToQuestion(index: currentQuestionIndex - 1)
        }
    }

    public func goToQuestion(index: Int) {
        guard let selectedExam, index >= 0, index < selectedExam.questions.count else { return }
        currentQuestionIndex = index
        playAudioForCurrentQuestion()
    }

    public func playAudioForCurrentQuestion() {
        guard let q = currentQuestion else { return }
        if let audioUrl = examService.resolveAudioUrl(for: q, testIndex: currentTestIndex) {
            audioPlayer.play(url: audioUrl)
        } else {
            audioPlayer.stop()
        }
    }

    public func resolveImageUrl(for question: ToeicQuestion) -> URL? {
        examService.resolveImageUrl(for: question, testIndex: currentTestIndex)
    }

    private func handleAudioFinishedInExamMode() {
        guard let selectedExam else { return }
        let currentAudio = currentQuestion?.audioUrl
        var nextIdx = currentQuestionIndex + 1

        // Part 3/4: Bỏ qua các câu dùng chung audio đã phát xong
        while nextIdx < selectedExam.questions.count &&
                selectedExam.questions[nextIdx].audioUrl != nil &&
                selectedExam.questions[nextIdx].audioUrl == currentAudio {
            nextIdx += 1
        }

        if nextIdx < selectedExam.questions.count {
            goToQuestion(index: nextIdx)
        }
    }

    // MARK: - Timer
    private func startTimer() {
        stopTimer()
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.secondsRemaining > 0 {
                self.secondsRemaining -= 1
            } else {
                self.submitExam()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
    }

    // MARK: - Submission
    public func submitExam() {
        stopTimer()
        audioPlayer.stop()
        guard let selectedExam else { return }

        var correctListening = 0
        var correctReading = 0

        for q in selectedExam.questions {
            if let userAns = userAnswers[q.number], userAns == q.correctOptionIndex {
                if q.part.isListening {
                    correctListening += 1
                } else {
                    correctReading += 1
                }
            }
        }

        let listeningScore = ToeicScoreConverter.convertToScale(correctListening, isListening: true)
        let readingScore = ToeicScoreConverter.convertToScale(correctReading, isListening: false)

        let result = ExamResult(
            examId: selectedExam.id,
            examTitle: selectedExam.title,
            userAnswers: userAnswers,
            correctListening: correctListening,
            correctReading: correctReading,
            listeningScore: listeningScore,
            readingScore: readingScore,
            timestamp: Date()
        )

        self.examResult = result
        self.isCompleted = true
    }

    public var formattedTimeRemaining: String {
        let minutes = secondsRemaining / 60
        let seconds = secondsRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    public func cleanup() {
        stopTimer()
        audioPlayer.stop()
    }
}
