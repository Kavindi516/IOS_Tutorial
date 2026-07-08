//
//  QuizQuestion.swift
//  LightItUp
//
//  Created by Student2 on 2026-07-03.
//

import Foundation

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

    // MARK: – Stable shuffled answers (computed ONCE, stored)
    // Previously this was a computed property that called .shuffled() on every access,
    // causing the answer order to jump around on every SwiftUI re-render.
    private(set) var stableShuffledAnswers: [String] = []

    // Decoded & cached — computed once, not on every View body call
    private(set) var decodedQuestion: String = ""
    private(set) var decodedCorrectAnswer: String = ""
    private(set) var decodedShuffledAnswers: [String] = []

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        question = try container.decode(String.self, forKey: .question)
        correctAnswer = try container.decode(String.self, forKey: .correctAnswer)
        incorrectAnswers = try container.decode([String].self, forKey: .incorrectAnswers)
        category = try container.decode(String.self, forKey: .category)
        difficulty = try container.decode(String.self, forKey: .difficulty)

        // Shuffle ONCE at decode time — this order is now stable
        stableShuffledAnswers = (incorrectAnswers + [correctAnswer]).shuffled()

        // Decode HTML entities ONCE (the old NSAttributedString path was very slow)
        decodedQuestion = question.htmlDecoded
        decodedCorrectAnswer = correctAnswer.htmlDecoded
        decodedShuffledAnswers = stableShuffledAnswers.map { $0.htmlDecoded }
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

// MARK: – Fast HTML entity decoder
// Open Trivia DB returns HTML-encoded strings like &amp; &#039; &quot; etc.
// The old NSAttributedString approach was extremely slow and caused visible lag.
extension String {
    var htmlDecoded: String {
        var result = self
        // Named entities (most common from Open Trivia DB)
        let namedEntities: [(String, String)] = [
            ("&amp;",   "&"),
            ("&lt;",    "<"),
            ("&gt;",    ">"),
            ("&quot;",  "\""),
            ("&apos;",  "'"),
            ("&laquo;", "«"),
            ("&raquo;", "»"),
            ("&ndash;", "–"),
            ("&mdash;", "—"),
            ("&hellip;", "…"),
            ("&trade;", "™"),
            ("&copy;",  "©"),
            ("&reg;",   "®"),
            ("&nbsp;",  " "),
            ("&shy;",   "\u{00AD}"),
            ("&ldquo;", "\u{201C}"),
            ("&rdquo;", "\u{201D}"),
            ("&lsquo;", "\u{2018}"),
            ("&rsquo;", "\u{2019}"),
        ]
        for (entity, char) in namedEntities {
            result = result.replacingOccurrences(of: entity, with: char)
        }

        // Numeric entities: &#039; &#123; etc.
        while let hashRange = result.range(of: "&#") {
            guard let semiRange = result.range(of: ";", range: hashRange.upperBound..<result.endIndex) else { break }
            let numStr = String(result[hashRange.upperBound..<semiRange.lowerBound])
            let fullEntity = result[hashRange.lowerBound..<semiRange.upperBound]
            if let code = UInt32(numStr), let scalar = Unicode.Scalar(code) {
                result = result.replacingOccurrences(of: fullEntity, with: String(scalar))
            } else {
                // Malformed entity — skip it to avoid infinite loop
                break
            }
        }

        return result
    }
}
