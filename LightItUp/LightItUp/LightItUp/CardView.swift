//
//  CardView.swift
//  LightItUp
//
//  Created by Student2 on 2026-06-19.
//

import SwiftUI
 
struct CardView: View {
    let card: Card
    let levelColor: Color
    let onTap: () -> Void
 
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(cardFill)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(card.isLit ? levelColor : Color.white.opacity(0.08),
                                  lineWidth: card.isLit ? 2 : 1)
            )
            .shadow(color: card.isLit ? levelColor.opacity(0.85) : .clear,
                    radius: card.isLit ? 18 : 0)
            .scaleEffect(card.isLit ? 1.06 : (card.justTapped ? 1.12 : 1.0))
            .animation(.spring(response: 0.3, dampingFraction: 0.55), value: card.isLit)
            .animation(.spring(response: 0.2, dampingFraction: 0.5), value: card.justTapped)
            .onTapGesture { onTap() }
    }
 
    private var cardFill: Color {
        if card.justTapped {
            return levelColor.opacity(0.5)
        }
        return card.isLit
            ? levelColor.opacity(0.30)
            : Color(white: 0.12)
    }
}
 
