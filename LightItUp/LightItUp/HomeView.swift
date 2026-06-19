//
//  ContentView.swift
//  LightItUp
//
//  Created by Student2 on 2026-06-19.
//

import SwiftUI
 
struct HomeView: View {
    @AppStorage("highScore_tapFrenzy") private var tapFrenzyBest: Int = 0
    @AppStorage("highScore_lightItUp") private var lightItUpBest: Int = 0
 
    var body: some View {
        NavigationStack {
            ZStack {
                // Dark gradient background
                LinearGradient(
                    colors: [Color(white: 0.06), Color(white: 0.10)],
                    startPoint: .top,
                    endPoint: .bottom
                ).ignoresSafeArea()
 
                VStack(spacing: 0) {
                    // Title block
                    VStack(spacing: 6) {
                        Text("CARD GAMES")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .kerning(3)
                            .foregroundColor(.gray)
                        Text("Choose a Mode")
                            .font(.system(size: 30, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 36)
 
                    // Mode buttons
                    VStack(spacing: 20) {
                        NavigationLink(destination: TapFrenzyView()) {
                            ModeCard(
                                icon: "hand.tap.fill",
                                title: "Tap Frenzy",
                                subtitle: "Tap as fast as you can in 30 seconds",
                                accentColor: Color(hex: "FF6B6B"),
                                best: tapFrenzyBest
                            )
                        }
                        .buttonStyle(.plain)
 
                        NavigationLink(destination: LightItUpView()) {
                            ModeCard(
                                icon: "lightbulb.fill",
                                title: "Light It Up",
                                subtitle: "Tap the lit card before it goes dark",
                                accentColor: Color(hex: "4FC3F7"),
                                best: lightItUpBest
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 24)
 
                    Spacer()
 
                    // Footer
                    Text("BSCCOMP25.1P · Week 2")
                        .font(.system(size: 11))
                        .foregroundColor(.gray.opacity(0.4))
                        .padding(.bottom, 24)
                }
            }
            .navigationBarHidden(true)
        }
    }
}
 
// MARK: – Mode card component
struct ModeCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let accentColor: Color
    let best: Int
 
    var body: some View {
        HStack(spacing: 20) {
            // Icon bubble
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(accentColor.opacity(0.18))
                    .frame(width: 64, height: 64)
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(accentColor)
            }
 
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .lineLimit(2)
                if best > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.yellow)
                        Text("Best: \(best)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.yellow)
                    }
                    .padding(.top, 2)
                }
            }
 
            Spacer()
 
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(20)
        .background(Color(white: 0.12))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(accentColor.opacity(0.25), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
 
#Preview {
    HomeView()
}

