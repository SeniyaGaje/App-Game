import Foundation
import SwiftUI
import Combine

@MainActor
final class QuizRushViewModel: ObservableObject {
    enum ViewState {
        case idle
        case loading
        case loaded
        case failed(String)
        case finished
    }
    
    @Published var state: ViewState = .idle
    @Published private(set) var questions: [OpenTriviaQuestion] = []
    @Published private(set) var currentIndex: Int = 0
    @Published private(set) var score: Int = 0
    @Published private(set) var streak: Int = 0
    @Published private(set) var correctCount: Int = 0
    @Published private(set) var selectedAnswer: String? = nil
    @Published private(set) var revealedCorrectAnswer: String? = nil
    @Published private(set) var answerFeedback: AnswerFeedback = .none
    @Published private(set) var isAnswerLocked: Bool = false
    
    let service: QuizRushService

    enum AnswerFeedback {
        case none
        case correct
        case incorrect
    }
    
    init(service: QuizRushService = .shared) {
        self.service = service
    }
    
    /// Load questions asynchronously, resetting state and score metrics.
    func load(amount: Int = 10) async {
        state = .loading
        score = 0
        streak = 0
        currentIndex = 0
        correctCount = 0
        selectedAnswer = nil
        revealedCorrectAnswer = nil
        answerFeedback = .none
        isAnswerLocked = false
        
        do {
            questions = try await service.fetchQuestions(amount: amount)
            state = .loaded
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
    
    /// Returns the current question if within bounds.
    func currentQuestion() -> OpenTriviaQuestion? {
        guard currentIndex >= 0, currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }
    
    /// Process an answer string, update score, streak and state accordingly.
    func answer(_ answer: String) {
        guard !isAnswerLocked else { return }
        guard let current = currentQuestion() else { return }

        isAnswerLocked = true
        selectedAnswer = answer
        revealedCorrectAnswer = current.correctAnswer
        
        if answer == current.correctAnswer {
            streak += 1
            score += 100 + (streak * 10)
            correctCount += 1
            answerFeedback = .correct
        } else {
            score = max(0, score - 25)
            streak = 0
            answerFeedback = .incorrect
        }

        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 650_000_000)
            guard let self else { return }
            self.advanceToNextQuestion()
        }
    }

    private func advanceToNextQuestion() {
        selectedAnswer = nil
        revealedCorrectAnswer = nil
        answerFeedback = .none
        isAnswerLocked = false

        currentIndex += 1

        if currentIndex >= questions.count {
            state = .finished
        }
    }
    
    /// Retry the quiz by reloading questions.
    func retry() async {
        await load()
    }
    
    /// Progress text in the format "currentIndex of totalQuestions"
    var progressText: String {
        "\(min(currentIndex + 1, questions.count)) of \(questions.count)"
    }

    var summaryText: String {
        "\(correctCount) / \(questions.count) correct"
    }
}
