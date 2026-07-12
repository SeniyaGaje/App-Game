import Foundation

/// Top-level response from Open Trivia DB.
struct OpenTriviaResponse: Codable {
    let results: [OpenTriviaQuestion]
}

/// A single multiple-choice trivia question from Open Trivia DB.
struct OpenTriviaQuestion: Codable, Identifiable, Equatable {
    let id = UUID()
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]
    
    /// Shuffled once at init time so the order stays stable across re-renders.
    let answersShuffled: [String]

    private enum CodingKeys: String, CodingKey {
        case question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let rawQ = try c.decode(String.self, forKey: .question)
        let rawCorrect = try c.decode(String.self, forKey: .correctAnswer)
        let rawIncorrect = try c.decode([String].self, forKey: .incorrectAnswers)
        self.question = rawQ.decodingHTMLEntities()
        self.correctAnswer = rawCorrect.decodingHTMLEntities()
        self.incorrectAnswers = rawIncorrect.map { $0.decodingHTMLEntities() }
        self.answersShuffled = (self.incorrectAnswers + [self.correctAnswer]).shuffled()
    }

    init(question: String, correctAnswer: String, incorrectAnswers: [String]) {
        self.question = question
        self.correctAnswer = correctAnswer
        self.incorrectAnswers = incorrectAnswers
        self.answersShuffled = (incorrectAnswers + [correctAnswer]).shuffled()
    }

    /// Convenience function to get shuffled answers.
    func allAnswersShuffled() -> [String] { answersShuffled }

    /// Compatibility helper for older view code expecting decodedQuestion()
    func decodedQuestion() -> String { question }

    /// Compatibility helper for older view code expecting decodedAnswers()
    func decodedAnswers() -> [String] { answersShuffled }
}

// Simple HTML entity decoding without UIKit/AppKit.
extension String {
    /// Decodes a small set of common HTML entities found in OpenTDB strings.
    func decodingHTMLEntities() -> String {
        var result = self

        let replacements: [String: String] = [
            "&quot;": "\"",
            "&#039;": "'",
            "&apos;": "'",
            "&amp;": "&",
            "&lt;": "<",
            "&gt;": ">",
            "&nbsp;": " ",
            "&ldquo;": "\"",
            "&rdquo;": "\"",
            "&lsquo;": "'",
            "&rsquo;": "'",
            "&eacute;": "é"
        ]

        for (entity, character) in replacements {
            result = result.replacingOccurrences(of: entity, with: character)
        }

        let numericEntityPattern = "&#(\\d+);"
        if let regex = try? NSRegularExpression(pattern: numericEntityPattern) {
            let nsString = result as NSString
            let matches = regex.matches(in: result, range: NSRange(location: 0, length: nsString.length))

            for match in matches.reversed() {
                guard match.numberOfRanges == 2 else { continue }
                let codeRange = match.range(at: 1)
                let fullRange = match.range(at: 0)
                guard let swiftCodeRange = Range(codeRange, in: result),
                      let code = Int(result[swiftCodeRange]),
                      let scalar = UnicodeScalar(code),
                      let swiftFullRange = Range(fullRange, in: result) else {
                    continue
                }

                result.replaceSubrange(swiftFullRange, with: String(Character(scalar)))
            }
        }

        return result
    }
}
