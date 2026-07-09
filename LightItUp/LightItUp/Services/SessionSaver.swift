//
//  SessionSaver.swift
//  LightItUp
//
//  Created by Student2 on 2026-07-08.
//

import Foundation
internal import _LocationEssentials

struct SessionSaver {
 
    static func save(mode: GameMode, score: Int) {
        let loc = LocationService.shared.lastLocation
        let session = GameSession(
            mode:      mode,
            score:     score,
            timestamp: Date(),
            latitude:  loc?.coordinate.latitude,
            longitude: loc?.coordinate.longitude
        )
        GameSession.save(session)
 
        // Notify StatsViewModel to reload
        NotificationCenter.default.post(name: .newSessionSaved, object: nil)
    }
}
