import Foundation
import SwiftUI

@MainActor
final class QuizRushViewModel: ObservableObject {
    @Published private(set) var questions: [TriviaQuestion] = []
    @Published private(set) var currentIndex: Int = 0
    @Published private(set) var score: Int = 0
    @Published private(set) var streak: Int = 0
    @Published var state: State = .idle
    @Published var lastAnswerWasCorrect: Bool? = nil
    
    let service: TriviaService
    
    enum State {
        case idle
        case loading
        case loaded
        case failed(Error)
        case finished
    }
    
    init(service: TriviaService = TriviaService()) {
        self.service = service
    }
    
    var currentQuestion: TriviaQuestion? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }
    
    var progressText: String {
        switch state {
        case .loaded, .finished:
            return "\(min(currentIndex + 1, 10)) of 10"
        default:
            return ""
        }
    }
    
    func load() async {
        state = .loading
        score = 0
        streak = 0
        currentIndex = 0
        lastAnswerWasCorrect = nil
        
        do {
            questions = try await service.fetchQuestions()
            state = .loaded
        } catch {
            state = .failed(error)
        }
    }
    
    func answerTapped(_ answer: String) {
        guard let current = currentQuestion else { return }
        
        if answer == current.correctAnswer {
            // Correct answer
            streak += 1
            let bonus = 20 * (streak - 1)
            score += 100 + bonus
            lastAnswerWasCorrect = true
        } else {
            // Wrong answer
            score = max(0, score - 25)
            streak = 0
            lastAnswerWasCorrect = false
        }
        
        currentIndex += 1
        
        if currentIndex >= 10 || currentIndex >= questions.count {
            state = .finished
        }
    }
    
    func restart() {
        currentIndex = 0
        score = 0
        streak = 0
        lastAnswerWasCorrect = nil
        state = .idle
    }
}
