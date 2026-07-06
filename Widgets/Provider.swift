//
//  Provider.swift
//  SalatWidget — Widget Extension
//
//  TimelineProvider that reads cached location + settings from the shared App
//  Group, computes today's and tomorrow's prayer times on-device, and emits one
//  timeline entry per prayer transition so the widget refreshes itself at each
//  prayer — no background task or network required.
//

import WidgetKit
import SwiftUI

/// One rendered state of the widget at a given moment.
struct SalatEntry: TimelineEntry {
    let date: Date
    /// The five obligatory prayers for the day that contains `date`.
    let dayTimes: [PrayerTime]
    /// The next upcoming timing relative to `date`, including sunrise
    /// (used by the Home Screen "Minimal Card" widget).
    let nextPrayer: PrayerTime?
    /// The current obligatory prayer window around `date` (Lock Screen widgets).
    /// `currentPrayer` is the most recent obligatory prayer, `nextObligatory`
    /// the next one — both may cross a day boundary.
    let currentPrayer: PrayerTime?
    let nextObligatory: PrayerTime?
    let locationName: String
    let theme: WidgetTheme
    let lockScreenStyle: LockScreenWidgetStyle
    /// False when we have no cached location yet (prompt the user to open the app).
    let hasLocation: Bool
}

struct SalatTimelineProvider: TimelineProvider {

    // Placeholder shown in the widget gallery / while loading.
    func placeholder(in context: Context) -> SalatEntry {
        .sample
    }

    func getSnapshot(in context: Context, completion: @escaping (SalatEntry) -> Void) {
        completion(currentEntry(for: Date()) ?? .sample)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SalatEntry>) -> Void) {
        let store = SharedStore.shared
        let settings = store.settings

        guard let coords = store.coordinates else {
            // No location yet — show a prompt and retry in an hour.
            let entry = SalatEntry.noLocation(theme: settings.widgetTheme,
                                              lockScreenStyle: settings.lockScreenStyle)
            completion(Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600))))
            return
        }

        let calendar = Calendar.current
        let now = Date()

        // Transition points: now, plus every prayer from now through tomorrow.
        var transitions: [Date] = [now]
        for dayOffset in 0...1 {
            if let day = calendar.date(byAdding: .day, value: dayOffset, to: now),
               let daily = PrayerTimeService.dailyTimes(for: day,
                                                        latitude: coords.latitude,
                                                        longitude: coords.longitude,
                                                        settings: settings,
                                                        calendar: calendar) {
                transitions.append(contentsOf: daily.times.map(\.date).filter { $0 > now })
            }
        }
        transitions.sort()

        let entries = transitions.compactMap {
            currentEntry(for: $0, coords: coords, settings: settings, calendar: calendar)
        }

        // Ask WidgetKit to rebuild the timeline tomorrow so it keeps rolling over.
        let reload = calendar.date(byAdding: .day, value: 1, to: now) ?? now.addingTimeInterval(86_400)
        let timeline = Timeline(entries: entries.isEmpty ? [.sample] : entries,
                                policy: .after(reload))
        completion(timeline)
    }

    // MARK: Entry construction

    private func currentEntry(for date: Date,
                              coords: (latitude: Double, longitude: Double),
                              settings: PrayerSettings,
                              calendar: Calendar) -> SalatEntry? {
        guard let daily = PrayerTimeService.dailyTimes(for: date,
                                                       latitude: coords.latitude,
                                                       longitude: coords.longitude,
                                                       settings: settings,
                                                       calendar: calendar) else {
            return nil
        }
        let next = PrayerTimeService.nextPrayer(after: date,
                                                latitude: coords.latitude,
                                                longitude: coords.longitude,
                                                settings: settings,
                                                calendar: calendar)
        let window = PrayerTimeService.obligatoryWindow(at: date,
                                                        latitude: coords.latitude,
                                                        longitude: coords.longitude,
                                                        settings: settings,
                                                        calendar: calendar)
        return SalatEntry(date: date,
                          dayTimes: daily.obligatory,
                          nextPrayer: next,
                          currentPrayer: window.current,
                          nextObligatory: window.next,
                          locationName: SharedStore.shared.locationName,
                          theme: settings.widgetTheme,
                          lockScreenStyle: settings.lockScreenStyle,
                          hasLocation: true)
    }

    private func currentEntry(for date: Date) -> SalatEntry? {
        let store = SharedStore.shared
        guard let coords = store.coordinates else { return nil }
        return currentEntry(for: date, coords: coords, settings: store.settings, calendar: .current)
    }
}

// MARK: - Fixtures

extension SalatEntry {

    /// A believable sample for previews and the widget gallery.
    static var sample: SalatEntry {
        let now = Date()
        let cal = Calendar.current
        let base = cal.startOfDay(for: now)
        func t(_ h: Int, _ m: Int) -> Date {
            cal.date(bySettingHour: h, minute: m, second: 0, of: base) ?? now
        }
        let times = [
            PrayerTime(prayer: .fajr,    date: t(5, 12)),
            PrayerTime(prayer: .dhuhr,   date: t(13, 24)),
            PrayerTime(prayer: .asr,     date: t(16, 58)),
            PrayerTime(prayer: .maghrib, date: t(20, 31)),
            PrayerTime(prayer: .isha,    date: t(22, 3))
        ]
        let next = times.first { $0.date > now } ?? times[0]
        let current = times.last { $0.date <= now }
        return SalatEntry(date: now,
                          dayTimes: times,
                          nextPrayer: next,
                          currentPrayer: current,
                          nextObligatory: next,
                          locationName: "Casablanca",
                          theme: .minimalCard,
                          lockScreenStyle: .ringCountdown,
                          hasLocation: true)
    }

    /// Shown when the app hasn't cached a location yet.
    static func noLocation(theme: WidgetTheme, lockScreenStyle: LockScreenWidgetStyle) -> SalatEntry {
        SalatEntry(date: Date(),
                   dayTimes: [],
                   nextPrayer: nil,
                   currentPrayer: nil,
                   nextObligatory: nil,
                   locationName: "—",
                   theme: theme,
                   lockScreenStyle: lockScreenStyle,
                   hasLocation: false)
    }
}
