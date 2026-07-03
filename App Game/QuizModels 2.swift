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

    /// A shuffled array of all answers (correct + incorrect).
    var answersShuffled: [String] {
        var all = incorrectAnswers + [correctAnswer]
        all.shuffle()
        return all
    }

    /// Convenience function to get shuffled answers.
    func allAnswersShuffled() -> [String] { answersShuffled }

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
    }

    init(question: String, correctAnswer: String, incorrectAnswers: [String]) {
        self.question = question
        self.correctAnswer = correctAnswer
        self.incorrectAnswers = incorrectAnswers
    }
}

// Simple HTML entity decoding without UIKit/AppKit.
extension String {
    /// Decodes a small set of common HTML entities found in OpenTDB strings.
    func decodingHTMLEntities() -> String {
        var s = self
        let map: [String: String] = [
            "&quot;": "\"",
            "&#039;": "'",
            "&amp;": "&",
            "&lt;": "<",
            "&gt;": ">",
            "&eacute;": "é"
        ]
        for (entity, char) in map {
            s = s.replacingOccurrences(of: entity, with: char)
        }
        // Replace numeric entities like &#34;
        let pattern = "&#(\\d+);"
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let ns = s as NSString
            var result = s
            let matches = regex.matches(in: s, options: [], range: NSRange(location: 0, length: ns.length))
            for match in matches.reversed() {
                if match.numberOfRanges == 2,
                   let range = Range(match.range(at: 1), in: s),
                   let code = Int(s[range]),
                   let scalar = UnicodeScalar(code) {
                    let fullRange = match.range(at: 0)
                    if let r = Range(fullRange, in: result) {
                        result.replaceSubrange(r, with: String(Character(scalar)))
                    }
                }
            }
            s = result
        }
        return s
    }
}
