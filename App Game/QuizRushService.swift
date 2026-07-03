import Foundation

final class QuizRushService {
    static let shared = QuizRushService()
    private init() {}

    /// Errors that can occur during network request or decoding.
    enum NetworkError: Error {
        case badURL
        case badStatus(Int)
        case decodingFailed
        case empty
    }

    /// Fetches trivia questions from Open Trivia DB.
    /// - Parameter amount: The number of questions to fetch. Defaults to 10.
    /// - Throws: NetworkError if URL is invalid, status code is not 200, decoding fails, or results are empty.
    /// - Returns: An array of `OpenTriviaQuestion`.
    func fetchQuestions(amount: Int = 10) async throws -> [OpenTriviaQuestion] {
        guard var components = URLComponents(string: "https://opentdb.com/api.php") else {
            throw NetworkError.badURL
        }

        components.queryItems = [
            URLQueryItem(name: "amount", value: "\(amount)"),
            URLQueryItem(name: "type", value: "multiple")
        ]

        guard let url = components.url else {
            throw NetworkError.badURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.badStatus(-1)
        }

        guard httpResponse.statusCode == 200 else {
            throw NetworkError.badStatus(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        do {
            let triviaResponse = try decoder.decode(OpenTriviaResponse.self, from: data)
            guard !triviaResponse.results.isEmpty else {
                throw NetworkError.empty
            }
            return triviaResponse.results
        } catch {
            throw NetworkError.decodingFailed
        }
    }
}
