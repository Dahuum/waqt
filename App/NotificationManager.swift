//
//  NotificationManager.swift
//  SalatWidget — App
//
//  Schedules local notifications for each prayer using UNUserNotificationCenter.
//  Everything is local; there is no push server. A custom adhan sound file is
//  referenced by name — replace `adhan.caf` in /Resources with a real short clip.
//

import Foundation
import UserNotifications

struct NotificationManager {

    static let shared = NotificationManager()

    /// How many days ahead to pre-schedule (iOS caps pending requests at 64).
    private let daysAhead = 5

    /// Ask for alert + sound permission. Returns whether it was granted.
    @discardableResult
    func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        return (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    /// Clear and rebuild the pending notifications from current settings.
    func reschedule(using settings: PrayerSettings, latitude: Double, longitude: Double) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        guard settings.notificationsEnabled else { return }

        let calendar = Calendar.current
        let now = Date()

        for dayOffset in 0..<daysAhead {
            guard
                let day = calendar.date(byAdding: .day, value: dayOffset, to: now),
                let daily = PrayerTimeService.dailyTimes(for: day,
                                                         latitude: latitude,
                                                         longitude: longitude,
                                                         settings: settings)
            else { continue }

            for prayerTime in daily.times where PrayerName.obligatory.contains(prayerTime.prayer) {
                guard settings.notify(for: prayerTime.prayer), prayerTime.date > now else { continue }
                schedule(prayerTime, calendar: calendar, center: center)
            }
        }
    }

    private func schedule(_ prayerTime: PrayerTime,
                          calendar: Calendar,
                          center: UNUserNotificationCenter) {
        let content = UNMutableNotificationContent()
        content.title = prayerTime.prayer.displayName
        content.body = "It's time for \(prayerTime.prayer.displayName) prayer."
        // Placeholder adhan sound — replace Resources/adhan.caf with a real clip
        // (<30s, CAF/AIFF/WAV). iOS falls back to the default sound if invalid.
        content.sound = UNNotificationSound(named: UNNotificationSoundName("adhan.caf"))

        let comps = calendar.dateComponents([.year, .month, .day, .hour, .minute],
                                            from: prayerTime.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let id = "\(prayerTime.prayer.rawValue)-\(Int(prayerTime.date.timeIntervalSince1970))"

        center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
    }
}
