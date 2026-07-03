import Foundation

/// The top-level response model for Open Trivia DB API results.
struct OpenTriviaResponse: Codable {
    /// An array of trivia questions returned from the API.
    let results: [OpenTriviaQuestion]
}

/// Represents a single trivia question with its answers.
struct OpenTriviaQuestion: Codable, Identifiable {
    /// A unique identifier for the question.
    let id = UUID()
    
    /// The trivia question text, with HTML entities decoded.
    let question: String
    
    /// The correct answer text, with HTML entities decoded.
    let correctAnswer: String
    
    /// The incorrect answers array, with HTML entities decoded.
    let incorrectAnswers: [String]
    
    /// Coding keys to map JSON keys to Swift property names.
    private enum CodingKeys: String, CodingKey {
        case question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }
    
    /// Decodes and initializes an instance from decoder, decoding HTML entities for all strings.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        question = try container.decode(String.self, forKey: .question).decodedHTML
        correctAnswer = try container.decode(String.self, forKey: .correctAnswer).decodedHTML
        let incorrectRaw = try container.decode([String].self, forKey: .incorrectAnswers)
        incorrectAnswers = incorrectRaw.map { $0.decodedHTML }
    }
    
    /// Returns a new array with all answers (correct + incorrect) shuffled.
    func allAnswersShuffled() -> [String] {
        var combined = incorrectAnswers
        combined.append(correctAnswer)
        return combined.shuffled()
    }
    
    /// A convenience property to get all answers shuffled.
    var answersShuffled: [String] {
        allAnswersShuffled()
    }
}

/// String extension that decodes a small set of common HTML entities.
private extension String {
    /// Returns a new string with common HTML entities decoded.
    var decodedHTML: String {
        var result = self
        let entities: [String: String] = [
            "&quot;": "\"",
            "&#039;": "'",
            "&amp;": "&",
            "&lt;": "<",
            "&gt;": ">"
        ]
        for (entity, character) in entities {
            result = result.replacingOccurrences(of: entity, with: character)
        }
        return result
    }
}
