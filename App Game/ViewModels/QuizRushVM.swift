import Foundation
import SwiftUI
import Combine

@MainActor
final class QuizRushViewModel: ObservableObject {
    enum ViewState: Equatable {
        case setup
        case loading
        case loaded
        case failed(String)
        case finished
    }
    
    @Published var state: ViewState = .setup
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
    
    struct Category: Hashable {
        let id: Int
        let name: String
    }
    
    let availableCategories: [Category] = [
        Category(id: 0, name: "Any Category"),
        Category(id: 9, name: "General Knowledge"),
        Category(id: 11, name: "Film"),
        Category(id: 12, name: "Music"),
        Category(id: 15, name: "Games"),
        Category(id: 17, name: "Science & Nature"),
        Category(id: 18, name: "Computers"),
        Category(id: 21, name: "Sports"),
        Category(id: 22, name: "Geography"),
        Category(id: 23, name: "History")
    ]
    
    let difficulties = ["any", "easy", "medium", "hard"]
    
    @Published var selectedCategoryId: Int = 0
    @Published var selectedDifficulty: String = "any"
    
    init(service: QuizRushService = .shared) {
        self.service = service
    }
    
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
            questions = try await service.fetchQuestions(
                amount: amount,
                categoryId: selectedCategoryId,
                difficulty: selectedDifficulty
            )
            state = .loaded
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
    
    func currentQuestion() -> OpenTriviaQuestion? {
        guard currentIndex >= 0, currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }
    
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
            let delay = answer == current.correctAnswer ? 750_000_000 : 2_200_000_000
            try? await Task.sleep(nanoseconds: UInt64(delay))
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
            let name = UserDefaults.standard.string(forKey: "playerName") ?? "Player 1"
            StatsVM.shared.addSession(mode: .quizRush, score: score, playerName: name)
        }
    }
    
    func retry() async {
        await load()
    }
    
    func resetToSetup() {
        state = .setup
    }
    
    var progressText: String {
        "\(min(currentIndex + 1, questions.count)) of \(questions.count)"
    }

    var summaryText: String {
        "\(correctCount) / \(questions.count) correct"
    }
}
