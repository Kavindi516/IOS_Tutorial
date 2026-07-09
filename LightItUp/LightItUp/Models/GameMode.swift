//
//  GameMode.swift
//  LightItUp
//
//  Created by Student2 on 2026-07-08.
//

import SwiftUI
 
enum GameMode: String, Codable, CaseIterable {
    case tapFrenzy  = "Tap Frenzy"
    case lightItUp  = "Light It Up"
    case quizRush   = "Quiz Rush"
 
    var icon: String {
        switch self {
        case .tapFrenzy: return "hand.tap.fill"
        case .lightItUp: return "lightbulb.fill"
        case .quizRush:  return "brain.head.profile"
        }
    }
 
    var color: Color {
        switch self {
        case .tapFrenzy: return Color(hex: "FF6B6B")
        case .lightItUp: return Color(hex: "4FC3F7")
        case .quizRush:  return Color(hex: "7B61FF")
        }
    }
 
    var highScoreKey: String {
        switch self {
        case .tapFrenzy: return "highScore_tapFrenzy"
        case .lightItUp: return "highScore_lightItUp"
        case .quizRush:  return "highScore_quizRush"
        }
    }
}
 
