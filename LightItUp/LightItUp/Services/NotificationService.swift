//
//  NotificationService.swift
//  LightItUp
//
//  Created by Student2 on 2026-07-08.
//

import UserNotifications
 
class NotificationService {
 
    static let shared = NotificationService()
    private let center = UNUserNotificationCenter.current()
 
    // MARK: – Permission
    func requestPermission() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }
 
    func checkPermission() async -> UNAuthorizationStatus {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus
    }
 
    // MARK: – Daily challenge notification
    // Cancels existing and reschedules at the chosen hour:minute every day
    func scheduleDailyChallenge(hour: Int, minute: Int) {
        center.removePendingNotificationRequests(withIdentifiers: ["dailyChallenge"])
 
        let content = UNMutableNotificationContent()
        content.title = "🎮 Daily Challenge Time!"
        content.body = "Your streak is waiting. Tap to play a quick round."
        content.sound = .default
 
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
 
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyChallenge", content: content, trigger: trigger)
 
        center.add(request)
    }
 
    // MARK: – Streak break reminder
    // Fires once if user hasn't played by a certain time
    func scheduleStreakReminder() {
        center.removePendingNotificationRequests(withIdentifiers: ["streakReminder"])
 
        let content = UNMutableNotificationContent()
        content.title = "🔥 Don't break your streak!"
        content.body = "You haven't played today. Do a quick round to keep it alive."
        content.sound = .default
 
        // Fires at 8 PM if not cancelled
        var dateComponents = DateComponents()
        dateComponents.hour = 20
        dateComponents.minute = 0
 
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "streakReminder", content: content, trigger: trigger)
 
        center.add(request)
    }
 
    func cancelAll() {
        center.removeAllPendingNotificationRequests()
    }
 
    func cancelDailyChallenge() {
        center.removePendingNotificationRequests(withIdentifiers: ["dailyChallenge"])
    }
}
