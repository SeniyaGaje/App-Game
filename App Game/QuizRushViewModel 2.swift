import Foundation
import SwiftUI

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
    @Published var lastAnswerWasCorrect: Bool? = nil
    
    let service: QuizRushService
    
    init(service: QuizRushService = .shared) {
        self.service = service
    }
    
    /// Load questions asynchronously, resetting state and score metrics.
    func load(amount: Int = 10) async {
        state = .loading
        score = 0
        streak = 0
        currentIndex = 0
        lastAnswerWasCorrect = nil
        
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
        guard let current = currentQuestion() else { return }
        
        if answer == current.correctAnswer {
            streak += 1
            score += 100 + (streak * 10)
            lastAnswerWasCorrect = true
        } else {
            score = max(0, score - 25)
            streak = 0
            lastAnswerWasCorrect = false
        }
        
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
}
