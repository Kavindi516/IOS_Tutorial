//
//  QuizRushView.swift
//  LightItUp
//
//  Created by Student2 on 2026-07-03.
//

import SwiftUI

struct QuizRushView: View {
    @StateObject private var vm = QuizViewModel()

    var body: some View {
        ZStack {
            // Background — deep navy, distinct from the other two games
            Color(hex: "080C14").ignoresSafeArea()

            switch vm.viewState {
            case .idle:
                startScreen
            case .loading:
                loadingScreen
            case .loaded:
                gameScreen
            case .results:
                resultsScreen
            case .failed(let msg):
                errorScreen(message: msg)
            }
        }
        .navigationTitle("Quiz Rush")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: – Start screen
    private var startScreen: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer(minLength: 20)

                // Hero
                VStack(spacing: 12) {
                    Text("🧠")
                        .font(.system(size: 72))
                    Text("Quiz Rush")
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Text("10 trivia questions. Live from the internet.\nHow smart are you really?")
                        .font(.system(size: 15))
                        .foregroundColor(Color(hex: "8899AA"))
                        .multilineTextAlignment(.center)
                }

                // Scoring legend
                VStack(spacing: 0) {
                    scoringRow(label: "Easy question correct", value: "+10 pts", color: "4CAF50")
                    Divider().background(Color.white.opacity(0.06))
                    scoringRow(label: "Medium question correct", value: "+20 pts", color: "FF9800")
                    Divider().background(Color.white.opacity(0.06))
                    scoringRow(label: "Hard question correct", value: "+30 pts", color: "F44336")
                    Divider().background(Color.white.opacity(0.06))
                    scoringRow(label: "Wrong answer", value: "−5 pts", color: "F44336")
                    Divider().background(Color.white.opacity(0.06))
                    scoringRow(label: "3-streak bonus", value: "+15 pts", color: "7B61FF")
                }
                .background(Color(white: 0.10))
                .clipShape(RoundedRectangle(cornerRadius: 16))

                // High score
                if vm.highScore > 0 {
                    HStack(spacing: 8) {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(.yellow)
                        Text("Your best: \(vm.highScore) pts")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.yellow)
                    }
                }

                // Play button
                Button { vm.startGame() } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "bolt.fill")
                        Text("START QUIZ")
                            .font(.system(size: 18, weight: .black, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "7B61FF"), Color(hex: "4FC3F7")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                Spacer(minLength: 20)
            }
            .padding(.horizontal, 24)
        }
    }

    private func scoringRow(label: String, value: String, color: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "8899AA"))
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: color))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: – Loading screen
    private var loadingScreen: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.4)
                .tint(Color(hex: "7B61FF"))
            Text("Fetching questions…")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color(hex: "8899AA"))
            Text("Connecting to Open Trivia DB")
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "8899AA").opacity(0.6))
        }
    }

    // MARK: – Error screen
    private func errorScreen(message: String) -> some View {
        VStack(spacing: 24) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 48))
                .foregroundColor(Color(hex: "F44336"))

            VStack(spacing: 8) {
                Text("Couldn't load questions")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text(message)
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "8899AA"))
                    .multilineTextAlignment(.center)
            }

            Button { vm.retry() } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                    Text("Try Again")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 14)
                .background(Color(hex: "7B61FF"))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding(.horizontal, 40)
    }

    // MARK: – Game screen
    private var gameScreen: some View {
        guard let q = vm.currentQuestion else { return AnyView(EmptyView()) }
        return AnyView(
            ScrollView {
                VStack(spacing: 20) {
                    // Progress bar + question counter
                    progressHeader

                    // Question card
                    questionCard(q)

                    // Answer buttons
                    answersGrid(q)

                    // Streak banner
                    if vm.streak >= 2 {
                        streakBanner
                    }

                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }
        )
    }

    private var progressHeader: some View {
        VStack(spacing: 8) {
            HStack {
                Text(vm.questionNumber)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(hex: "8899AA"))
                Spacer()
                // Score
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.yellow)
                    Text("\(vm.score)")
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                }
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 5)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "7B61FF"), Color(hex: "4FC3F7")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * vm.progress, height: 5)
                        .animation(.easeInOut(duration: 0.4), value: vm.progress)
                }
            }
            .frame(height: 5)
        }
    }

    private func questionCard(_ q: QuizQuestion) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category + difficulty row
            HStack(spacing: 8) {
                Text(q.category)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color(hex: "8899AA"))
                    .lineLimit(1)
                Spacer()
                // Difficulty pill
                Text(q.difficulty.uppercased())
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(hex: q.difficultyColor))
                    .clipShape(Capsule())
            }

            // Question text
            Text(q.decodedQuestion)
                .font(.system(size: 19, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(3)
        }
        .padding(20)
        .background(Color(white: 0.11))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(Color(hex: "7B61FF").opacity(0.25), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18))
        // Green/red flash overlay on answer
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .fill(flashOverlayColor)
                .animation(.easeInOut(duration: 0.2), value: vm.answerResult)
        )
    }

    private var flashOverlayColor: Color {
        switch vm.answerResult {
        case .correct: return Color(hex: "4CAF50").opacity(0.12)
        case .wrong:   return Color(hex: "F44336").opacity(0.12)
        case .none:    return .clear
        }
    }

    private func answersGrid(_ q: QuizQuestion) -> some View {
        VStack(spacing: 10) {
            ForEach(q.decodedShuffledAnswers, id: \.self) { answer in
                AnswerButton(
                    text: answer,
                    state: buttonState(for: answer, correct: q.decodedCorrectAnswer),
                    onTap: { vm.submitAnswer(answer) }
                )
            }
        }
    }

    private func buttonState(for answer: String, correct: String) -> AnswerButtonState {
        guard let selected = vm.selectedAnswer else { return .idle }

        if answer == correct {
            return .correct      // always highlight correct in green
        }
        if answer == selected {
            return .wrong        // highlight the wrong one tapped in red
        }
        return .idle
    }

    private var streakBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "flame.fill")
                .foregroundColor(Color(hex: "FF9800"))
            Text("\(vm.streak) in a row!")
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundColor(Color(hex: "FF9800"))
            if vm.streak % 3 == 0 {
                Text("+15 bonus")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(hex: "FFD700"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color(hex: "FFD700").opacity(0.15))
                    .clipShape(Capsule())
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(hex: "FF9800").opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.spring(response: 0.35), value: vm.streak)
    }

    // MARK: – Results screen
    private var resultsScreen: some View {
        ScrollView {
            VStack(spacing: 28) {
                Spacer(minLength: 20)

                // Trophy / result icon
                ZStack {
                    Circle()
                        .fill(Color(hex: "7B61FF").opacity(0.15))
                        .frame(width: 100, height: 100)
                    Text(resultEmoji)
                        .font(.system(size: 50))
                }

                // Final score
                VStack(spacing: 6) {
                    if vm.score >= vm.highScore && vm.score > 0 {
                        Text("NEW BEST!")
                            .font(.system(size: 12, weight: .black))
                            .foregroundColor(.yellow)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                            .background(Color.yellow.opacity(0.15))
                            .clipShape(Capsule())
                    }
                    Text("\(vm.score)")
                        .font(.system(size: 72, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .monospacedDigit()
                    Text("POINTS")
                        .font(.system(size: 12, weight: .semibold))
                        .kerning(2)
                        .foregroundColor(Color(hex: "8899AA"))
                }

                // Stats row
                HStack(spacing: 0) {
                    resultStat(label: "Best Streak", value: "🔥 \(vm.bestStreak)")
                    Divider()
                        .frame(height: 40)
                        .background(Color.white.opacity(0.08))
                    resultStat(label: "All-time Best", value: "🏆 \(vm.highScore)")
                }
                .background(Color(white: 0.11))
                .clipShape(RoundedRectangle(cornerRadius: 16))

                // Motivational message
                Text(motivationalMessage)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "8899AA"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                // Action buttons
                VStack(spacing: 12) {
                    Button { vm.startGame() } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.clockwise")
                            Text("PLAY AGAIN")
                                .font(.system(size: 16, weight: .black, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "7B61FF"), Color(hex: "4FC3F7")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    
                    ShareLink(
                        item: "I just scored \(vm.score) on Quiz Rush — beat that! 🧠",
                        subject: Text("Quiz Rush Score"),
                        message: Text("Can you beat \(vm.score) points?")
                    ) {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share Score")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundColor(Color(hex: "4FC3F7"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(white: 0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    Button { vm.reset() } label: {
                        Text("Home")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color(hex: "8899AA"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(white: 0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }

                Spacer(minLength: 20)
            }
            .padding(.horizontal, 24)
        }
    }

    private func resultStat(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color(hex: "8899AA"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }

    private var resultEmoji: String {
        switch vm.score {
        case 200...: return "🏆"
        case 150...: return "🥇"
        case 100...: return "🥈"
        case 50...:  return "🥉"
        default:     return "💡"
        }
    }

    private var motivationalMessage: String {
        switch vm.score {
        case 200...: return "Flawless. You're basically a walking encyclopedia."
        case 150...: return "Impressive. You clearly pay attention to things."
        case 100...: return "Solid round. A few more and you'll crack 200."
        case 50...:  return "Not bad for a warm-up. Try again?"
        default:     return "Every wrong answer is a fact you'll never forget. Go again."
        }
    }
}

#Preview {
    NavigationStack {
        QuizRushView()
    }
}

