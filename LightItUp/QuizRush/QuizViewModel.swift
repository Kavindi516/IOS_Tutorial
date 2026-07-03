//
//  QuizViewModel.swift
//  LightItUp
//
//  Created by Student2 on 2026-07-03.
//

import SwiftUI
internal import Combine

// MARK: – View-state enum
// Drives which screen the View renders.
// One enum, one switch — no boolean soup.
enum QuizViewState {
    case idle         // haven't started yet (start screen)
    case loading      // fetching from API
    case loaded       // questions ready, game in progress
    case results      // all 10 answered — show final screen
    case failed(String) // network/decode error with message
}

// MARK: – Answer result (drives animation)
enum AnswerResult {
    case none, correct, wrong
}

@MainActor
class QuizViewModel: ObservableObject {

    // MARK: – Published state (View reads these)
    @Published var viewState: QuizViewState = .idle
    @Published var questions: [QuizQuestion] = []
    @Published var currentIndex: Int = 0
    @Published var score: Int = 0
    @Published var streak: Int = 0          // consecutive correct answers
    @Published var bestStreak: Int = 0
    @Published var answerResult: AnswerResult = .none
    @Published var selectedAnswer: String? = nil
    @Published var isAnswerLocked: Bool = false  // prevents double-tap during feedback

    // Persisted high score — separate key per mode
    @AppStorage("highScore_quizRush") var highScore: Int = 0

    // MARK: – Computed helpers the View uses
    var currentQuestion: QuizQuestion? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentIndex) / Double(questions.count)
    }

    var questionNumber: String {
        "\(currentIndex + 1) of \(questions.count)"
    }

    // Points awarded per correct answer — scales with difficulty
    private func points(for question: QuizQuestion) -> Int {
        switch question.difficulty {
        case "easy":   return 10
        case "medium": return 20
        case "hard":   return 30
        default:       return 10
        }
    }

    // Streak bonus: every 3 correct in a row adds +15
    private var streakBonus: Int {
        streak > 0 && streak % 3 == 0 ? 15 : 0
    }

    // MARK: – Public API the View calls

    // Start a fresh round
    func startGame() {
        viewState = .loading
        currentIndex = 0
        score = 0
        streak = 0
        bestStreak = 0
        answerResult = .none
        selectedAnswer = nil
        isAnswerLocked = false
        questions = []

        Task {
            do {
                let fetched = try await TriviaService.fetchQuestions(amount: 10)
                questions = fetched
                viewState = .loaded
            } catch {
                viewState = .failed(error.localizedDescription)
            }
        }
    }

    // Called when player taps an answer button
    func submitAnswer(_ answer: String) {
        guard !isAnswerLocked, let q = currentQuestion else { return }
        isAnswerLocked = true
        selectedAnswer = answer

        let isCorrect = answer == q.decodedCorrectAnswer

        if isCorrect {
            streak += 1
            if streak > bestStreak { bestStreak = streak }
            let bonus = streakBonus
            score += points(for: q) + bonus
            answerResult = .correct
        } else {
            streak = 0
            score = max(0, score - 5)   // small penalty, can't go below 0
            answerResult = .wrong
        }

        // Show result briefly, then advance
        Task {
            try? await Task.sleep(nanoseconds: 900_000_000)  // 0.9s feedback window
            advance()
        }
    }

    // Move to next question or end the round
    private func advance() {
        answerResult = .none
        selectedAnswer = nil
        isAnswerLocked = false

        let next = currentIndex + 1
        if next >= questions.count {
            // Round complete
            if score > highScore { highScore = score }
            viewState = .results
        } else {
            currentIndex = next
        }
    }

    // Retry after network failure
    func retry() {
        startGame()
    }

    // Go back to idle (home/start screen)
    func reset() {
        viewState = .idle
        questions = []
        currentIndex = 0
        score = 0
        streak = 0
        bestStreak = 0
        answerResult = .none
        selectedAnswer = nil
        isAnswerLocked = false
    }
}

