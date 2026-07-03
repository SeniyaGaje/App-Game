import Foundation

enum TriviaServiceError: Error {
    case invalidURL
    case badStatusCode(Int)
}

struct TriviaService {
    func fetchQuestions() async throws -> [TriviaQuestion] {
        guard let url = URL(string: "https://opentdb.com/api.php?amount=10&type=multiple") else {
            throw TriviaServiceError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw TriviaServiceError.badStatusCode(statusCode)
        }
        
        let decoder = JSONDecoder()
        let triviaResponse = try decoder.decode(TriviaResponse.self, from: data)
        return triviaResponse.results
    }
}
