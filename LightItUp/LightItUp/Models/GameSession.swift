//
//  GameSession.swift
//  LightItUp
//
//  Created by Student2 on 2026-07-08.
//

import Foundation
import CoreLocation
 
struct GameSession: Codable, Identifiable {
    var id: UUID = UUID()
    var mode: GameMode
    var score: Int
    var timestamp: Date
    var latitude: Double?   // nil if location permission denied
    var longitude: Double?
 
    // Human-readable date for Stats list
    var formattedDate: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: timestamp)
    }
 
    var coordinate: CLLocationCoordinate2D? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}
 
// MARK: – Persistence
extension GameSession {
    static let storageKey = "gameSessions_v1"
 
    // Load all sessions from UserDefaults
    static func loadAll() -> [GameSession] {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([GameSession].self, from: data)
        else { return [] }
        return decoded
    }
 
    // Append a new session and save
    static func save(_ session: GameSession) {
        var all = loadAll()
        all.append(session)
        if let encoded = try? JSONEncoder().encode(all) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
 
    // Delete all sessions
    static func deleteAll() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
}
 
