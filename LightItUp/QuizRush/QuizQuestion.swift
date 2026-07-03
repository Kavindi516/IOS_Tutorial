//
//  QuizQuestion.swift
//  LightItUp
//
//  Created by Student2 on 2026-07-03.
//

import Foundation
internal import UIKit

// Outer wrapper — matches the top-level JSON object
struct TriviaResponse: Codable {
    let results: [QuizQuestion]
}

// One question from the API
struct QuizQuestion: Codable, Identifiable {
    // Identifiable conformance — API has no id so we generate one
    var id = UUID()

    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]
    let category: String
    let difficulty: String

    // Map snake_case JSON keys to camelCase Swift properties
    enum CodingKeys: String, CodingKey {
        case question
        case correctAnswer    = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
        case category
        case difficulty
    }

    // All four answer options shuffled — computed so it's always available
    var shuffledAnswers: [String] {
        (incorrectAnswers + [correctAnswer]).shuffled()
    }

    // Decoded question text — API HTML-encodes special chars like &amp; &#039;
    var decodedQuestion: String {
        question.htmlDecoded
    }

    // Decoded correct answer
    var decodedCorrectAnswer: String {
        correctAnswer.htmlDecoded
    }

    // Decoded shuffled answers
    var decodedShuffledAnswers: [String] {
        shuffledAnswers.map { $0.htmlDecoded }
    }

    // Difficulty as a display colour name (used in UI)
    var difficultyColor: String {
        switch difficulty {
        case "easy":   return "4CAF50"   // green
        case "medium": return "FF9800"   // orange
        case "hard":   return "F44336"   // red
        default:       return "9E9E9E"
        }
    }
}

// HTML entity decoder — Open Trivia DB returns HTML-encoded strings
extension String {
    var htmlDecoded: String {
        guard let data = data(using: .utf8) else { return self }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        guard let attributed = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return self
        }
        return attributed.string
    }
}
