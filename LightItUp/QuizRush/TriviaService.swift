//
//  TriviaService.swift
//  LightItUp
//
//  Created by Student2 on 2026-07-03.
//

import Foundation

struct TriviaService {

    // MARK: – API config (one place to change if needed)
    private static let baseURL = "https://opentdb.com/api.php"

    // My own choices: 10 questions, multiple choice only
    // I also allow any category so rounds feel varied
    static func url(amount: Int = 10) -> URL {
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "amount", value: "\(amount)"),
            URLQueryItem(name: "type",   value: "multiple")
        ]
        return components.url!
    }

    // MARK: – Fetch
    // Throws on network error or bad HTTP status.
    // The ViewModel catches and sets .failed state.
    static func fetchQuestions(amount: Int = 10) async throws -> [QuizQuestion] {
        let (data, response) = try await URLSession.shared.data(from: url(amount: amount))

        // Guard on HTTP status
        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            throw TriviaError.badStatus(http.statusCode)
        }

        let decoded = try JSONDecoder().decode(TriviaResponse.self, from: data)

        // Open Trivia DB returns response_code 0 on success
        guard !decoded.results.isEmpty else {
            throw TriviaError.noQuestions
        }

        return decoded.results
    }
}

// MARK: – Typed errors (shown in the error UI)
enum TriviaError: LocalizedError {
    case badStatus(Int)
    case noQuestions

    var errorDescription: String? {
        switch self {
        case .badStatus(let code): return "Server returned status \(code). Try again."
        case .noQuestions:         return "No questions came back. Try again."
        }
    }
}
