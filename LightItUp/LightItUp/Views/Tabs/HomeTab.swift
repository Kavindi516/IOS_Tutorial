//
//  HomeTab.swift
//  LightItUp
//
//  Created by Student2 on 2026-07-08.
//

import SwiftUI
 
struct HomeTab: View {
    @EnvironmentObject var statsVM: StatsViewModel
    @AppStorage("highScore_tapFrenzy") private var tapFrenzyBest: Int = 0
    @AppStorage("highScore_lightItUp") private var lightItUpBest: Int = 0
    @AppStorage("highScore_quizRush")  private var quizRushBest:  Int = 0
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
 
    @State private var showNotificationBanner = false
    @State private var dailyChallengeMode: GameMode? = nil
    @State private var navigateToDailyChallenge = false
 
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(white: 0.06), Color(white: 0.10)],
                    startPoint: .top, endPoint: .bottom
                ).ignoresSafeArea()
 
                ScrollView {
                    VStack(spacing: 20) {
                        // Streak banner
                        streakBanner
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
 
                        // Daily challenge card
                        dailyChallengeCard
                            .padding(.horizontal, 20)
 
                        // Title
                        VStack(spacing: 4) {
                            Text("GAME MODES")
                                .font(.system(size: 11, weight: .semibold))
                                .kerning(3)
                                .foregroundColor(.gray)
                            Text("Choose a Mode")
                                .font(.system(size: 28, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 4)
 
                        // Game mode cards
                        VStack(spacing: 16) {
                            NavigationLink(destination: TapFrenzyView()) {
                                ModeCard(icon: "hand.tap.fill",
                                         title: "Tap Frenzy",
                                         subtitle: "Tap as fast as you can in 30 seconds",
                                         accentColor: Color(hex: "FF6B6B"),
                                         best: tapFrenzyBest)
                            }.buttonStyle(.plain)
 
                            NavigationLink(destination: LightItUpView()) {
                                ModeCard(icon: "lightbulb.fill",
                                         title: "Light It Up",
                                         subtitle: "Tap the lit card before it goes dark",
                                         accentColor: Color(hex: "4FC3F7"),
                                         best: lightItUpBest)
                            }.buttonStyle(.plain)
 
                            NavigationLink(destination: QuizRushView()) {
                                ModeCard(icon: "brain.head.profile",
                                         title: "Quiz Rush",
                                         subtitle: "10 live trivia questions",
                                         accentColor: Color(hex: "7B61FF"),
                                         best: quizRushBest)
                            }.buttonStyle(.plain)
                        }
                        .padding(.horizontal, 20)
 
                        Spacer(minLength: 20)
 
                        Text("BSCCOMP25.1P · Week 4")
                            .font(.system(size: 11))
                            .foregroundColor(.gray.opacity(0.4))
                            .padding(.bottom, 8)
                    }
                }
 
                // Hidden navigation for daily challenge
                NavigationLink(
                    destination: dailyChallengeDestination,
                    isActive: $navigateToDailyChallenge
                ) { EmptyView() }
            }
            .navigationTitle("PlayHub")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    notificationBell
                }
            }
        }
    }
 
    // MARK: – Streak banner
    private var streakBanner: some View {
        HStack(spacing: 14) {
            Text("🔥")
                .font(.system(size: 28))
 
            VStack(alignment: .leading, spacing: 2) {
                Text("\(statsVM.currentStreak) day streak")
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text(statsVM.playedToday
                     ? "You've played today. Keep it up!"
                     : "⚠️ Play today to keep your streak!")
                    .font(.system(size: 12))
                    .foregroundColor(statsVM.playedToday
                                     ? Color(hex: "8899AA")
                                     : Color(hex: "FF9800"))
            }
 
            Spacer()
 
            if statsVM.currentStreak > 0 {
                Text("\(statsVM.currentStreak)")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundColor(Color(hex: "FF9800"))
            }
        }
        .padding(16)
        .background(Color(white: 0.12))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    statsVM.playedToday
                    ? Color(hex: "FF9800").opacity(0.3)
                    : Color(hex: "FF9800").opacity(0.6),
                    lineWidth: 1
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
 
    // MARK: – Daily challenge card
    private var dailyChallengeCard: some View {
        Button {
            // Pick a random mode for the daily challenge
            dailyChallengeMode = GameMode.allCases.randomElement()
            navigateToDailyChallenge = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "7B61FF").opacity(0.2))
                        .frame(width: 48, height: 48)
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: "7B61FF"))
                }
 
                VStack(alignment: .leading, spacing: 3) {
                    Text("DAILY CHALLENGE")
                        .font(.system(size: 10, weight: .black))
                        .kerning(1.5)
                        .foregroundColor(Color(hex: "7B61FF"))
                    Text(statsVM.playedToday ? "Completed! Play another round" : "Tap to start today's challenge")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white)
                }
 
                Spacer()
 
                Image(systemName: statsVM.playedToday ? "checkmark.circle.fill" : "chevron.right")
                    .foregroundColor(statsVM.playedToday ? Color(hex: "4CAF50") : .gray)
            }
            .padding(16)
            .background(Color(white: 0.12))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color(hex: "7B61FF").opacity(0.3), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
 
    // MARK: – Notification bell
    private var notificationBell: some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: notificationsEnabled ? "bell.fill" : "bell.slash.fill")
                .foregroundColor(notificationsEnabled ? Color(hex: "7B61FF") : .gray)
                .font(.system(size: 18))
 
            // Red dot if not played today
            if !statsVM.playedToday && notificationsEnabled {
                Circle()
                    .fill(Color.red)
                    .frame(width: 8, height: 8)
                    .offset(x: 4, y: -4)
            }
        }
    }
 
    // MARK: – Daily challenge destination
    @ViewBuilder
    private var dailyChallengeDestination: some View {
        switch dailyChallengeMode {
        case .tapFrenzy:  TapFrenzyView()
        case .lightItUp:  LightItUpView()
        case .quizRush:   QuizRushView()
        case nil:         QuizRushView()
        }
    }
}
 
// MARK: – ModeCard (moved here from HomeView — single source of truth)
struct ModeCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let accentColor: Color
    let best: Int
 
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(accentColor.opacity(0.18))
                    .frame(width: 60, height: 60)
                Image(systemName: icon)
                    .font(.system(size: 26))
                    .foregroundColor(accentColor)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .lineLimit(2)
                if best > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "trophy.fill").font(.system(size: 10)).foregroundColor(.yellow)
                        Text("Best: \(best)").font(.system(size: 11, weight: .semibold)).foregroundColor(.yellow)
                    }
                    .padding(.top, 1)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(18)
        .background(Color(white: 0.12))
        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(accentColor.opacity(0.25), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}
 
