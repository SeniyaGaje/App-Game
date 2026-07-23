import Foundation

final class QuizRushService {
    static let shared = QuizRushService()
    private init() {}

    enum NetworkError: Error {
        case badURL
        case badStatus(Int)
        case decodingFailed
        case empty
    }

    // Fetch quiz from openDb api
    func fetchQuestions(amount: Int = 10, categoryId: Int? = nil, difficulty: String? = nil) async throws -> [OpenTriviaQuestion] {
        guard var components = URLComponents(string: "https://opentdb.com/api.php") else {
            throw NetworkError.badURL
        }

        var queryItems = [
            URLQueryItem(name: "amount", value: "\(amount)"),
            URLQueryItem(name: "type", value: "multiple")
        ]
        
        if let categoryId = categoryId, categoryId != 0 {
            queryItems.append(URLQueryItem(name: "category", value: "\(categoryId)"))
        }
        
        if let difficulty = difficulty, difficulty != "any" {
            queryItems.append(URLQueryItem(name: "difficulty", value: difficulty))
        }
        
        components.queryItems = queryItems

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
