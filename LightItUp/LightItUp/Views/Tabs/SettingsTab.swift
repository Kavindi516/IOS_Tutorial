//
//  SettingsTab.swift
//  LightItUp
//
//  Created by Student2 on 2026-07-08.
//

import SwiftUI
 
struct SettingsTab: View {
    @EnvironmentObject var statsVM: StatsViewModel
 
    @AppStorage("notificationsEnabled")    private var notificationsEnabled: Bool = true
    @AppStorage("dailyChallengeHour")      private var dailyChallengeHour: Int = 9
    @AppStorage("dailyChallengeMinute")    private var dailyChallengeMinute: Int = 0
    @AppStorage("highScore_tapFrenzy")     private var tapFrenzyBest: Int = 0
    @AppStorage("highScore_lightItUp")     private var lightItUpBest: Int = 0
    @AppStorage("highScore_quizRush")      private var quizRushBest:  Int = 0
 
    @State private var showResetConfirm = false
    @State private var notificationStatus = "Unknown"
    @State private var selectedTime = Date()
 
    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.06).ignoresSafeArea()
 
                List {
                    // MARK: Notifications section
                    Section {
                        // Toggle
                        HStack {
                            Label("Enable Notifications", systemImage: "bell.fill")
                                .foregroundColor(.white)
                            Spacer()
                            Toggle("", isOn: $notificationsEnabled)
                                .tint(Color(hex: "7B61FF"))
                                .onChange(of: notificationsEnabled) { _, enabled in
                                    handleNotificationToggle(enabled)
                                }
                        }
 
                        // Time picker (only when enabled)
                        if notificationsEnabled {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Daily Challenge Time", systemImage: "clock.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 15))
 
                                DatePicker(
                                    "",
                                    selection: $selectedTime,
                                    displayedComponents: .hourAndMinute
                                )
                                .datePickerStyle(.wheel)
                                .labelsHidden()
                                .frame(maxWidth: .infinity)
                                .onChange(of: selectedTime) { _, newTime in
                                    let cal = Calendar.current
                                    let h = cal.component(.hour, from: newTime)
                                    let m = cal.component(.minute, from: newTime)
                                    dailyChallengeHour = h
                                    dailyChallengeMinute = m
                                    NotificationService.shared.scheduleDailyChallenge(hour: h, minute: m)
                                }
 
                                Text("You'll get a daily reminder at this time.")
                                    .font(.system(size: 11))
                                    .foregroundColor(Color(hex: "8899AA"))
                            }
                            .padding(.vertical, 4)
 
                            // Streak reminder
                            HStack {
                                Label("Streak Reminder (8 PM)", systemImage: "flame.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 14))
                                Spacer()
                                Text("Auto")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(hex: "8899AA"))
                            }
                        }
                    } header: {
                        Text("Notifications")
                            .foregroundColor(Color(hex: "8899AA"))
                    }
                    .listRowBackground(Color(white: 0.12))
 
                    // MARK: Stats section
                    Section {
                        HStack {
                            Label("Total Games", systemImage: "gamecontroller.fill")
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(statsVM.totalGames)")
                                .foregroundColor(Color(hex: "8899AA"))
                        }
 
                        HStack {
                            Label("Current Streak", systemImage: "flame.fill")
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(statsVM.currentStreak) days")
                                .foregroundColor(Color(hex: "FF9800"))
                        }
 
                        // Reset button
                        Button(role: .destructive) {
                            showResetConfirm = true
                        } label: {
                            HStack {
                                Image(systemName: "trash.fill")
                                Text("Reset All Stats")
                            }
                        }
                        .confirmationDialog(
                            "Reset all stats?",
                            isPresented: $showResetConfirm,
                            titleVisibility: .visible
                        ) {
                            Button("Reset Everything", role: .destructive) {
                                statsVM.deleteAll()
                                tapFrenzyBest = 0
                                lightItUpBest = 0
                                quizRushBest  = 0
                            }
                            Button("Cancel", role: .cancel) {}
                        } message: {
                            Text("This will delete all your game history and high scores. This cannot be undone.")
                        }
 
                    } header: {
                        Text("Your Stats")
                            .foregroundColor(Color(hex: "8899AA"))
                    }
                    .listRowBackground(Color(white: 0.12))
 
                    // MARK: About section
                    Section {
                        HStack {
                            Label("Version", systemImage: "info.circle.fill")
                                .foregroundColor(.white)
                            Spacer()
                            Text("Week 4 · BSCCOMP25.1P")
                                .foregroundColor(Color(hex: "8899AA"))
                                .font(.system(size: 12))
                        }
                    } header: {
                        Text("About")
                            .foregroundColor(Color(hex: "8899AA"))
                    }
                    .listRowBackground(Color(white: 0.12))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                // Set the picker to the stored time
                var components = DateComponents()
                components.hour = dailyChallengeHour
                components.minute = dailyChallengeMinute
                if let date = Calendar.current.date(from: components) {
                    selectedTime = date
                }
                // Request permission on first open
                Task {
                    _ = await NotificationService.shared.requestPermission()
                }
            }
        }
    }
 
    private func handleNotificationToggle(_ enabled: Bool) {
        if enabled {
            Task {
                let granted = await NotificationService.shared.requestPermission()
                if granted {
                    NotificationService.shared.scheduleDailyChallenge(
                        hour: dailyChallengeHour,
                        minute: dailyChallengeMinute
                    )
                    NotificationService.shared.scheduleStreakReminder()
                }
            }
        } else {
            NotificationService.shared.cancelAll()
        }
    }
}
