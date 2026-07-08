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

    // Over-fetch to guarantee enough unique questions after dedup
    static func url(amount: Int = 15) -> URL {
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
    // Fetches extra questions and deduplicates to avoid repeats.
    static func fetchQuestions(amount: Int = 10) async throws -> [QuizQuestion] {
        // Request more than needed so we can deduplicate
        let fetchCount = amount + 5
        let (data, response) = try await URLSession.shared.data(from: url(amount: fetchCount))

        // Guard on HTTP status
        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            throw TriviaError.badStatus(http.statusCode)
        }

        let decoded = try JSONDecoder().decode(TriviaResponse.self, from: data)

        // Open Trivia DB returns response_code 0 on success
        guard !decoded.results.isEmpty else {
            throw TriviaError.noQuestions
        }

        // Deduplicate by question text — API can return the same question twice
        var seen = Set<String>()
        var unique: [QuizQuestion] = []
        for q in decoded.results {
            if seen.insert(q.decodedQuestion).inserted {
                unique.append(q)
            }
            if unique.count >= amount { break }
        }

        guard !unique.isEmpty else {
            throw TriviaError.noQuestions
        }

        return Array(unique.prefix(amount))
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
