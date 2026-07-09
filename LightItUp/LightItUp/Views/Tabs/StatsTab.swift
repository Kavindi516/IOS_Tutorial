//
//  StatsTab.swift
//  LightItUp
//
//  Created by Student2 on 2026-07-08.
//

import SwiftUI
import Charts
 
struct StatsTab: View {
    @EnvironmentObject var statsVM: StatsViewModel
    @State private var selectedMode: GameMode = .tapFrenzy
 
    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.06).ignoresSafeArea()
 
                if statsVM.sessions.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Overview cards
                            overviewRow
                                .padding(.horizontal, 20)
                                .padding(.top, 8)
 
                            // Personal bests
                            personalBests
                                .padding(.horizontal, 20)
 
                            // Bar chart
                            chartSection
                                .padding(.horizontal, 20)
 
                            // Recent games
                            recentGames
                                .padding(.horizontal, 20)
 
                            Spacer(minLength: 20)
                        }
                    }
                }
            }
            .navigationTitle("Stats")
            .navigationBarTitleDisplayMode(.large)
        }
    }
 
    // MARK: – Empty state
    private var emptyState: some View {
        VStack(spacing: 16) {
            Text("📊")
                .font(.system(size: 60))
            Text("No games yet")
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundColor(.white)
            Text("Play any mode to see your stats here.")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "8899AA"))
        }
    }
 
    // MARK: – Overview row (total games + streak)
    private var overviewRow: some View {
        HStack(spacing: 12) {
            overviewCard(value: "\(statsVM.totalGames)", label: "Total Games", icon: "gamecontroller.fill", color: "7B61FF")
            overviewCard(value: "\(statsVM.currentStreak)", label: "Day Streak", icon: "flame.fill", color: "FF9800")
            overviewCard(value: "\(statsVM.overallBest)", label: "All-time Best", icon: "trophy.fill", color: "FFD700")
        }
    }
 
    private func overviewCard(value: String, label: String, icon: String, color: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Color(hex: color))
            Text(value)
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(Color(hex: "8899AA"))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(white: 0.11))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
 
    // MARK: – Personal bests per mode
    private var personalBests: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Personal Bests")
 
            ForEach(GameMode.allCases, id: \.self) { mode in
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(mode.color.opacity(0.18))
                            .frame(width: 40, height: 40)
                        Image(systemName: mode.icon)
                            .font(.system(size: 18))
                            .foregroundColor(mode.color)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(mode.rawValue)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        Text("\(statsVM.totalGames(for: mode)) games played")
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: "8899AA"))
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(statsVM.bestScore(for: mode))")
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundColor(mode.color)
                        Text("best score")
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "8899AA"))
                    }
                }
                .padding(14)
                .background(Color(white: 0.11))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
    }
 
    // MARK: – Bar chart section
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Score History")
 
            // Mode picker
            Picker("Mode", selection: $selectedMode) {
                ForEach(GameMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
 
            let chartData = statsVM.chartSessions(for: selectedMode)
 
            if chartData.isEmpty {
                Text("No games played in this mode yet.")
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "8899AA"))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 30)
            } else {
                Chart(chartData) { session in
                    BarMark(
                        x: .value("Game", session.formattedDate),
                        y: .value("Score", session.score)
                    )
                    .foregroundStyle(selectedMode.color)
                    .cornerRadius(4)
                }
                .chartXAxis(.hidden)  // dates are too long — hide X axis labels
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine().foregroundStyle(Color.white.opacity(0.06))
                        AxisValueLabel()
                            .foregroundStyle(Color(hex: "8899AA"))
                    }
                }
                .frame(height: 160)
                .padding(.vertical, 8)
            }
        }
        .padding(16)
        .background(Color(white: 0.11))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
 
    // MARK: – Recent games list
    private var recentGames: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Recent Games")
 
            ForEach(statsVM.recentSessions) { session in
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(session.mode.color.opacity(0.15))
                            .frame(width: 36, height: 36)
                        Image(systemName: session.mode.icon)
                            .font(.system(size: 16))
                            .foregroundColor(session.mode.color)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(session.mode.rawValue)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                        Text(session.formattedDate)
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: "8899AA"))
                    }
                    Spacer()
                    Text("\(session.score) pts")
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .foregroundColor(session.mode.color)
                }
                .padding(12)
                .background(Color(white: 0.11))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
 
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 16, weight: .black, design: .rounded))
            .foregroundColor(.white)
    }
}
