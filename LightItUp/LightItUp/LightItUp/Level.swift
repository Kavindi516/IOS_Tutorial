//
//  Level.swift
//  LightItUp
//
//  Created by Student2 on 2026-06-19.
//

import SwiftUI
 
enum Level: Int, CaseIterable {
    case l1 = 1, l2, l3, l4
 
    // How many seconds into the 60-s round this level starts
    var startsAt: Double {
        switch self {
        case .l1: return 0
        case .l2: return 15
        case .l3: return 30
        case .l4: return 45
        }
    }
 
    // My own card-count choices (different from the brief)
    var cardCount: Int {
        switch self {
        case .l1: return 4   // 1×4 row
        case .l2: return 6   // 2×3 grid
        case .l3: return 9   // 3×3 grid
        case .l4: return 12  // 3×4 grid
        }
    }
 
    // Number of columns in the grid
    var columns: Int {
        switch self {
        case .l1: return 4
        case .l2: return 3
        case .l3: return 3
        case .l4: return 4
        }
    }
 
    // How long (seconds) a card stays lit before going dark
    var litWindow: Double {
        switch self {
        case .l1: return 1.6
        case .l2: return 1.2
        case .l3: return 0.9
        case .l4: return 0.65
        }
    }
 
    // How many cards are lit simultaneously
    var litCount: Int {
        switch self {
        case .l1, .l2, .l3: return 1
        case .l4: return 2
        }
    }
 
    // Glow/accent colour for this level (neon arcade palette)
    var color: Color {
        switch self {
        case .l1: return Color(hex: "4FC3F7")  // sky blue
        case .l2: return Color(hex: "69F0AE")  // mint green
        case .l3: return Color(hex: "FFD740")  // amber
        case .l4: return Color(hex: "FF5252")  // hot red
        }
    }
 
    var label: String { "L\(rawValue)" }
}
 
// Determine current level from elapsed seconds
extension Level {
    static func current(elapsed: Double) -> Level {
        if elapsed >= 45 { return .l4 }
        if elapsed >= 30 { return .l3 }
        if elapsed >= 15 { return .l2 }
        return .l1
    }
}
 


