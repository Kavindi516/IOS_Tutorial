//
//  LightItUpViewModel.swift
//  LightItUp
//
//  Created by Student2 on 2026-06-19.
//

import SwiftUI
internal import Combine
 
class LightItUpViewModel: ObservableObject {
 
    // MARK: – Published state
    @Published var cards: [Card] = []
    @Published var score: Int = 0
    @Published var lives: Int = 3          // 3-lives system (bonus requirement)
    @Published var timeRemaining: Double = 60
    @Published var currentLevel: Level = .l1
    @Published var isRunning: Bool = false
    @Published var isGameOver: Bool = false
    @Published var showLevelFlash: Bool = false   // level-up flash overlay (bonus)
    @Published var newHighScore: Bool = false
 
    // @AppStorage is used in the view; ViewModel just reads/writes via UserDefaults directly
    // so it doesn't need SwiftUI property wrappers (avoids @MainActor issues)
    private let highScoreKey = "highScore_lightItUp"
    var highScore: Int {
        get { UserDefaults.standard.integer(forKey: highScoreKey) }
        set { UserDefaults.standard.set(newValue, forKey: highScoreKey) }
    }
 
    // MARK: – Private
    private var roundTimer: AnyCancellable?
    private var litTimer: AnyCancellable?
    private var roundLength: Double = 60
    private var elapsed: Double = 0
 
    // Track which cards are currently lit so we can auto-dim them
    private var litCardIDs: Set<Int> = []
 
    // MARK: – Start
    func start(roundLength: Double = 60) {
        self.roundLength = roundLength
        timeRemaining = roundLength
        elapsed = 0
        score = 0
        lives = 3
        isGameOver = false
        newHighScore = false
        currentLevel = .l1
        rebuildCards(for: .l1)
        isRunning = true
 
        startRoundTimer()
        scheduleLitCycle()
    }
 
    func reset() {
        roundTimer?.cancel()
        litTimer?.cancel()
        isRunning = false
        isGameOver = false
        cards = []
        score = 0
        lives = 3
        timeRemaining = 60
        elapsed = 0
        currentLevel = .l1
        litCardIDs = []
    }
 
    // MARK: – Tap handling
    func tap(card: Card) {
        guard isRunning else { return }
 
        if card.isLit {
            // Correct tap
            withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                if let idx = cards.firstIndex(where: { $0.id == card.id }) {
                    cards[idx].isLit = false
                    cards[idx].justTapped = true
                    litCardIDs.remove(card.id)
                }
            }
            score += pointsForCurrentLevel()
            // Reset flash flag after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if let idx = self.cards.firstIndex(where: { $0.id == card.id }) {
                    self.cards[idx].justTapped = false
                }
            }
        } else {
            // Wrong tap
            applyPenalty()
        }
    }
 
    private func pointsForCurrentLevel() -> Int {
        switch currentLevel {
        case .l1: return 10
        case .l2: return 15
        case .l3: return 20
        case .l4: return 30
        }
    }
 
    private func applyPenalty() {
        lives -= 1
        score = max(0, score - 5)
        if lives <= 0 {
            endGame()
        }
    }
 
    // MARK: – Round timer (ticks every 0.1 s for smooth countdown)
    private func startRoundTimer() {
        roundTimer?.cancel()
        roundTimer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                self.elapsed += 0.1
                self.timeRemaining = max(0, self.roundLength - self.elapsed)
 
                let newLevel = Level.current(elapsed: self.elapsed)
                if newLevel != self.currentLevel {
                    self.advanceToLevel(newLevel)
                }
 
                if self.timeRemaining <= 0 {
                    self.endGame()
                }
            }
    }
 
    // MARK: – Lit cycle timer (lights up cards at current lit-window interval)
    private func scheduleLitCycle() {
        litTimer?.cancel()
        let interval = currentLevel.litWindow
        litTimer = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.lightUpNewCards()
            }
    }
 
    private func lightUpNewCards() {
        guard isRunning, !cards.isEmpty else { return }
 
        // Penalise any cards that are still lit (player missed them)
        for id in litCardIDs {
            applyPenalty()
            if !isRunning { return }  // game might have ended mid-loop
        }
 
        // Dim all cards
        for i in cards.indices {
            cards[i].isLit = false
        }
        litCardIDs.removeAll()
 
        // Pick random cards to light up
        let count = min(currentLevel.litCount, cards.count)
        let chosen = cards.shuffled().prefix(count)
        withAnimation(.easeIn(duration: 0.15)) {
            for card in chosen {
                if let idx = cards.firstIndex(where: { $0.id == card.id }) {
                    cards[idx].isLit = true
                    litCardIDs.insert(card.id)
                }
            }
        }
    }
 
    // MARK: – Level progression
    private func advanceToLevel(_ level: Level) {
        currentLevel = level
        rebuildCards(for: level)
        // Level-up flash overlay
        showLevelFlash = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.showLevelFlash = false
        }
        // Restart lit cycle with new interval
        scheduleLitCycle()
    }
 
    private func rebuildCards(for level: Level) {
        // Dim all existing, then resize array
        litCardIDs.removeAll()
        cards = (0..<level.cardCount).map { Card(id: $0) }
    }
 
    // MARK: – End game
    private func endGame() {
        roundTimer?.cancel()
        litTimer?.cancel()
        isRunning = false
        isGameOver = true
 
        // Dim all cards
        for i in cards.indices { cards[i].isLit = false }
 
        if score > highScore {
            highScore = score
            newHighScore = true
        }
        SessionSaver.save(mode: .lightItUp, score: score) 
    }
}
