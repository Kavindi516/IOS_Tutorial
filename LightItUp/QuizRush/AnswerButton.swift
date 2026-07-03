//
//  AnswerButton.swift
//  LightItUp
//
//  Created by Student2 on 2026-07-03.
//

import SwiftUI

enum AnswerButtonState {
    case idle       // not yet answered
    case correct    // this was the right answer
    case wrong      // this was tapped and it was wrong
    case revealed   // the round answered — show correct answer in green
}

// MARK: – Custom button style with press-down feedback
// Gives instant visual feedback: the button scales down when pressed
// so the user can SEE they tapped it (the old .plain style gave zero feedback)
struct AnswerPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct AnswerButton: View {
    let text: String
    let state: AnswerButtonState
    let onTap: () -> Void

    @State private var shakeOffset: CGFloat = 0

    var body: some View {
        Button(action: {
            guard state == .idle else { return }
            onTap()
        }) {
            HStack(spacing: 12) {
                // Left accent strip
                RoundedRectangle(cornerRadius: 2)
                    .fill(stripColor)
                    .frame(width: 4)
                    .padding(.vertical, 4)

                Text(text)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                // Result icon
                if state != .idle {
                    Image(systemName: iconName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(stripColor)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(borderColor, lineWidth: state == .idle ? 1 : 1.5)
            )
        }
        .buttonStyle(AnswerPressButtonStyle())
        .offset(x: shakeOffset)
        .onChange(of: state) { _, newState in
            if newState == .wrong {
                triggerShake()
            }
        }
        .animation(.easeInOut(duration: 0.2), value: state)
    }

    // MARK: – Derived colours

    private var stripColor: Color {
        switch state {
        case .idle:     return Color(hex: "7B61FF")   // brand purple
        case .correct:  return Color(hex: "4CAF50")   // green
        case .wrong:    return Color(hex: "F44336")   // red
        case .revealed: return Color(hex: "4CAF50")   // green reveal
        }
    }

    private var textColor: Color {
        switch state {
        case .idle:     return .white
        case .correct:  return Color(hex: "A5D6A7")
        case .wrong:    return Color(hex: "EF9A9A")
        case .revealed: return Color(hex: "A5D6A7")
        }
    }

    private var background: Color {
        switch state {
        case .idle:     return Color(white: 0.12)
        case .correct:  return Color(hex: "4CAF50").opacity(0.15)
        case .wrong:    return Color(hex: "F44336").opacity(0.15)
        case .revealed: return Color(hex: "4CAF50").opacity(0.10)
        }
    }

    private var borderColor: Color {
        switch state {
        case .idle:     return Color.white.opacity(0.08)
        case .correct:  return Color(hex: "4CAF50").opacity(0.6)
        case .wrong:    return Color(hex: "F44336").opacity(0.6)
        case .revealed: return Color(hex: "4CAF50").opacity(0.4)
        }
    }

    private var iconName: String {
        switch state {
        case .correct, .revealed: return "checkmark.circle.fill"
        case .wrong:              return "xmark.circle.fill"
        default:                  return ""
        }
    }

    // MARK: – Shake animation for wrong answer
    private func triggerShake() {
        let offsets: [CGFloat] = [0, -8, 8, -6, 6, -4, 4, 0]
        for (i, offset) in offsets.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.06) {
                withAnimation(.linear(duration: 0.06)) {
                    shakeOffset = offset
                }
            }
        }
    }
}

// Hex colour extension — same as Level.swift but kept here
// so AnswerButton.swift is self-contained if needed
// (Remove this if you already have it in Level.swift to avoid redeclaration)
// extension Color {
//     init(hex: String) { ... }
// }
