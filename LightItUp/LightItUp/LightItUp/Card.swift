//
//  Card.swift
//  LightItUp
//
//  Created by Student2 on 2026-06-19.
//

import Foundation

struct Card: Identifiable {
    let id: Int
    var isLit: Bool = false
    var justTapped: Bool = false  // drives a brief flash animation
}
