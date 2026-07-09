//
//  StatsViewModel.swift
//  LightItUp
//
//  Created by Student2 on 2026-07-08.
//

import SwiftUI
internal import Combine
 
@MainActor
class StatsViewModel: ObservableObject {
 
    @Published var sessions: [GameSession] = []
 
    init() {
        load()
        // Listen for new sessions saved by any game mode
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reload),
            name: .newSessionSaved,
            object: nil
        )
    }
 
    @objc private func reload() { load() }
 
    func load() {
        sessions = GameSession.loadAll().sorted { $0.timestamp > $1.timestamp }
    }
 
    func deleteAll() {
        GameSession.deleteAll()
        sessions = []
    }
 
    // MARK: – Computed stats
 
    var totalGames: Int { sessions.count }
 
    var recentSessions: [GameSession] {
        Array(sessions.prefix(10))
    }
 
    func sessions(for mode: GameMode) -> [GameSession] {
        sessions.filter { $0.mode == mode }
    }
 
    func bestScore(for mode: GameMode) -> Int {
        sessions(for: mode).map { $0.score }.max() ?? 0
    }
 
    func totalGames(for mode: GameMode) -> Int {
        sessions(for: mode).count
    }
 
    // Bar chart data: last 10 sessions per mode, chronological order
    func chartSessions(for mode: GameMode) -> [GameSession] {
        Array(sessions(for: mode).reversed().suffix(10))
    }
 
    // Overall best across all modes
    var overallBest: Int {
        sessions.map { $0.score }.max() ?? 0
    }
 
    // Streak: consecutive days the user played (going back from today)
    var currentStreak: Int {
        guard !sessions.isEmpty else { return 0 }
        let calendar = Calendar.current
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())
 
        let playedDays = Set(sessions.map { calendar.startOfDay(for: $0.timestamp) })
 
        while playedDays.contains(checkDate) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = previous
        }
        return streak
    }
 
    // Today's challenge: has the user played at least one game today?
    var playedToday: Bool {
        let calendar = Calendar.current
        return sessions.contains { calendar.isDateInToday($0.timestamp) }
    }
}
 
// Notification name for cross-ViewModel communication
extension Notification.Name {
    static let newSessionSaved = Notification.Name("newSessionSaved")
}
