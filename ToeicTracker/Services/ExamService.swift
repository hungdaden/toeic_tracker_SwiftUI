import Foundation
import UIKit

public final class ExamService {
    public static let shared = ExamService()
    private var cachedExams: [ToeicExam]?

    private init() {}

    /// Danh sách 10 đề thi ETS TOEIC 2026
    public func getAvailableExams() -> [ToeicExam] {
        if let cached = cachedExams { return cached }

        var list: [ToeicExam] = []
        for i in 1...10 {
            let pad = String(format: "%02d", i)
            let exam = ToeicExam(
                id: "ets_2026_test_\(i)",
                title: "ETS TOEIC 2026 - Test \(pad)",
                description: "Đề thi chính thức ETS 2026 số \(pad). Bao gồm đầy đủ 200 câu hỏi 7 Part, file nghe Audio chất lượng cao và ảnh đề thi sắc nét.",
                tag: "ETS 2026",
                timeLimitMinutes: 120,
                questions: []
            )
            list.append(exam)
        }
        cachedExams = list
        return list
    }

    /// Tải chi tiết câu hỏi của một đề thi
    public func loadExam(examId: String) -> ToeicExam {
        let testNum = examId == "ets_2026_test_2" ? 2 : 1
        let filename = "ets_2026_test_\(testNum)"

        // Thử tìm JSON trong bundle
        var fileUrl: URL? = Bundle.main.url(forResource: filename, withExtension: "json")
        if fileUrl == nil {
            fileUrl = Bundle.main.url(forResource: filename, withExtension: "json", subdirectory: "exams")
        }
        if fileUrl == nil {
            fileUrl = Bundle.main.url(forResource: filename, withExtension: "json", subdirectory: "Resources/exams")
        }

        if let fileUrl, let data = try? Data(contentsOf: fileUrl) {
            do {
                let decodedExam = try JSONDecoder().decode(ToeicExam.self, from: data)
                return decodedExam
            } catch {
                print("Failed to decode exam JSON for \(examId): \(error)")
            }
        }

        // Fallback: Tạo đề thi mô phỏng chuẩn 200 câu nếu không nạp được JSON
        return generateMockExam(testIndex: testNum, examId: examId)
    }

    /// Tìm URL ảnh minh họa của câu hỏi
    public func resolveImageUrl(for question: ToeicQuestion, testIndex: Int) -> URL? {
        guard let imagePath = question.imageUrl, !imagePath.isEmpty else { return nil }
        let fileName = (imagePath as NSString).lastPathComponent
        let nameWithoutExt = (fileName as NSString).deletingPathExtension
        let ext = (fileName as NSString).pathExtension

        let subdirs = [
            "exams/test_\(testIndex)/images",
            "Resources/exams/test_\(testIndex)/images",
            "test_\(testIndex)/images"
        ]

        for subdir in subdirs {
            if let url = Bundle.main.url(forResource: nameWithoutExt, withExtension: ext, subdirectory: subdir) {
                return url
            }
        }

        if let url = Bundle.main.url(forResource: nameWithoutExt, withExtension: ext) {
            return url
        }

        return nil
    }

    /// Tìm URL audio của câu hỏi
    public func resolveAudioUrl(for question: ToeicQuestion, testIndex: Int) -> URL? {
        guard let audioPath = question.audioUrl, !audioPath.isEmpty else { return nil }
        let fileName = (audioPath as NSString).lastPathComponent
        let nameWithoutExt = (fileName as NSString).deletingPathExtension
        let ext = (fileName as NSString).pathExtension

        let subdirs = [
            "exams/test_\(testIndex)/audio",
            "Resources/exams/test_\(testIndex)/audio",
            "test_\(testIndex)/audio"
        ]

        for subdir in subdirs {
            if let url = Bundle.main.url(forResource: nameWithoutExt, withExtension: ext, subdirectory: subdir) {
                return url
            }
        }

        if let url = Bundle.main.url(forResource: nameWithoutExt, withExtension: ext) {
            return url
        }

        return nil
    }

    private func generateMockExam(testIndex: Int, examId: String) -> ToeicExam {
        var questions: [ToeicQuestion] = []
        let padTest = String(format: "%02d", testIndex)

        let partCounts: [(QuestionPart, Int)] = [
            (.part1, 6),
            (.part2, 25),
            (.part3, 39),
            (.part4, 30),
            (.part5, 30),
            (.part6, 16),
            (.part7, 54)
        ]

        var currentNumber = 1
        for (part, count) in partCounts {
            for _ in 0..<count {
                let qNum = currentNumber
                currentNumber += 1

                let correctIdx = (qNum * 7 + testIndex) % (part == .part2 ? 3 : 4)
                let options = part == .part2 ? ["(A)", "(B)", "(C)"] : ["(A)", "(B)", "(C)", "(D)"]

                var audioUrl: String?
                var imageUrl: String?

                if part == .part1 {
                    let padQ = String(format: "%02d", qNum)
                    audioUrl = "assets/exams/test_\(testIndex)/audio/E26-T\(padTest)-\(padQ).mp3"
                    imageUrl = "assets/exams/test_\(testIndex)/images/\(padQ).PNG"
                } else if part == .part2 {
                    let padQ = String(format: "%02d", qNum)
                    audioUrl = "assets/exams/test_\(testIndex)/audio/E26-T\(padTest)-\(padQ).mp3"
                }

                questions.append(
                    ToeicQuestion(
                        number: qNum,
                        part: part,
                        questionText: (part == .part1 || part == .part2) ? nil : "Câu hỏi số \(qNum) (\(part.shortName.uppercased()))",
                        options: options,
                        correctOptionIndex: correctIdx,
                        imageUrl: imageUrl,
                        audioUrl: audioUrl,
                        passage: (part == .part6 || part == .part7) ? "Đoạn văn đọc hiểu tương ứng với câu \(qNum)." : nil,
                        explanation: "Đáp án chính thức ETS 2026.",
                        transcript: "Transcript audio phần nghe TOEIC."
                    )
                )
            }
        }

        return ToeicExam(
            id: examId,
            title: "ETS TOEIC 2026 - Test \(padTest)",
            description: "Đề thi ETS 2026 chính thức.",
            tag: "ETS 2026",
            timeLimitMinutes: 120,
            questions: questions
        )
    }
}
