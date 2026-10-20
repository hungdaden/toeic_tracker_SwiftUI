import Foundation

public enum QuestionPart: String, Codable, CaseIterable, Identifiable {
    case part1
    case part2
    case part3
    case part4
    case part5
    case part6
    case part7

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .part1: return "Part 1: Photographs"
        case .part2: return "Part 2: Question - Response"
        case .part3: return "Part 3: Conversations"
        case .part4: return "Part 4: Short Talks"
        case .part5: return "Part 5: Incomplete Sentences"
        case .part6: return "Part 6: Text Completion"
        case .part7: return "Part 7: Reading Comprehension"
        }
    }

    public var shortName: String {
        switch self {
        case .part1: return "Part 1"
        case .part2: return "Part 2"
        case .part3: return "Part 3"
        case .part4: return "Part 4"
        case .part5: return "Part 5"
        case .part6: return "Part 6"
        case .part7: return "Part 7"
        }
    }

    public var isListening: Bool {
        self == .part1 || self == .part2 || self == .part3 || self == .part4
    }

    public var isReading: Bool {
        !isListening
    }
}

public struct ToeicQuestion: Identifiable, Codable, Equatable, Hashable {
    public var id: Int { number }
    public let number: Int
    public let part: QuestionPart
    public let questionText: String?
    public let options: [String]
    public let correctOptionIndex: Int
    public let imageUrl: String?
    public let audioUrl: String?
    public let passage: String?
    public let explanation: String?
    public let transcript: String?

    public init(
        number: Int,
        part: QuestionPart,
        questionText: String? = nil,
        options: [String] = ["(A)", "(B)", "(C)", "(D)"],
        correctOptionIndex: Int = 0,
        imageUrl: String? = nil,
        audioUrl: String? = nil,
        passage: String? = nil,
        explanation: String? = nil,
        transcript: String? = nil
    ) {
        self.number = number
        self.part = part
        self.questionText = questionText
        self.options = options
        self.correctOptionIndex = correctOptionIndex
        self.imageUrl = imageUrl
        self.audioUrl = audioUrl
        self.passage = passage
        self.explanation = explanation
        self.transcript = transcript
    }

    enum CodingKeys: String, CodingKey {
        case number
        case part
        case questionText
        case options
        case correctOptionIndex
        case imageUrl
        case audioUrl
        case passage
        case explanation
        case transcript
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.number = try container.decodeIfPresent(Int.self, forKey: .number) ?? 1
        
        let partStr = try? container.decode(String.self, forKey: .part)
        self.part = QuestionPart(rawValue: partStr ?? "part1") ?? .part1
        
        self.questionText = try container.decodeIfPresent(String.self, forKey: .questionText)
        self.options = try container.decodeIfPresent([String].self, forKey: .options) ?? ["(A)", "(B)", "(C)", "(D)"]
        self.correctOptionIndex = try container.decodeIfPresent(Int.self, forKey: .correctOptionIndex) ?? 0
        self.imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        self.audioUrl = try container.decodeIfPresent(String.self, forKey: .audioUrl)
        self.passage = try container.decodeIfPresent(String.self, forKey: .passage)
        self.explanation = try container.decodeIfPresent(String.self, forKey: .explanation)
        self.transcript = try container.decodeIfPresent(String.self, forKey: .transcript)
    }
}

public struct ToeicExam: Identifiable, Codable, Equatable, Hashable {
    public let id: String
    public let title: String
    public let description: String?
    public let tag: String?
    public let timeLimitMinutes: Int
    public var questions: [ToeicQuestion]

    public init(
        id: String,
        title: String,
        description: String? = nil,
        tag: String? = "ETS 2026",
        timeLimitMinutes: Int = 120,
        questions: [ToeicQuestion] = []
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.tag = tag
        self.timeLimitMinutes = timeLimitMinutes
        self.questions = questions
    }

    public var totalQuestions: Int {
        questions.count
    }

    public var listeningQuestions: [ToeicQuestion] {
        questions.filter { $0.part.isListening }
    }

    public var readingQuestions: [ToeicQuestion] {
        questions.filter { $0.part.isReading }
    }
}

public struct ExamResult: Identifiable, Codable, Equatable {
    public var id: String { "\(examId)_\(timestamp.timeIntervalSince1970)" }
    public let examId: String
    public let examTitle: String
    public let userAnswers: [Int: Int] // Question number -> chosen index
    public let correctListening: Int
    public let correctReading: Int
    public let listeningScore: Int
    public let readingScore: Int
    public let timestamp: Date

    public init(
        examId: String,
        examTitle: String,
        userAnswers: [Int: Int],
        correctListening: Int,
        correctReading: Int,
        listeningScore: Int,
        readingScore: Int,
        timestamp: Date = Date()
    ) {
        self.examId = examId
        self.examTitle = examTitle
        self.userAnswers = userAnswers
        self.correctListening = correctListening
        self.correctReading = correctReading
        self.listeningScore = listeningScore
        self.readingScore = readingScore
        self.timestamp = timestamp
    }

    public var totalScore: Int {
        listeningScore + readingScore
    }
}
