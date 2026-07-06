//
//  PrayerModels.swift
//  SalatWidget — Shared
//
//  Plain data models for prayer timings. This file is compiled into BOTH the
//  main app and the widget extension, so it must not depend on either.
//

import Foundation

/// The six daily timings we track: the five obligatory prayers plus sunrise.
///
/// We use our own name here (`PrayerName`) so it never collides with Adhan's
/// own `Prayer` type inside `PrayerTimeService`.
enum PrayerName: String, CaseIterable, Codable, Identifiable {
    case fajr
    case sunrise
    case dhuhr
    case asr
    case maghrib
    case isha

    var id: String { rawValue }

    /// Human-readable label used throughout the UI and widgets.
    var displayName: String {
        switch self {
        case .fajr:    return "Fajr"
        case .sunrise: return "Sunrise"
        case .dhuhr:   return "Dhuhr"
        case .asr:     return "Asr"
        case .maghrib: return "Maghrib"
        case .isha:    return "Isha"
        }
    }

    /// Short label for tight layouts (e.g. accessory / small widgets).
    var shortName: String {
        switch self {
        case .fajr:    return "Fajr"
        case .sunrise: return "Shrq"
        case .dhuhr:   return "Dhhr"
        case .asr:     return "Asr"
        case .maghrib: return "Mgrb"
        case .isha:    return "Isha"
        }
    }

    /// 3-letter uppercase abbreviation for very tight layouts (grids, rings).
    var abbreviation: String {
        switch self {
        case .fajr:    return "FJR"
        case .sunrise: return "SHR"
        case .dhuhr:   return "DHR"
        case .asr:     return "ASR"
        case .maghrib: return "MGB"
        case .isha:    return "ISH"
        }
    }

    /// SF Symbol used consistently across all widgets for this timing.
    var symbolName: String {
        switch self {
        case .fajr:    return "sunrise"
        case .sunrise: return "sunrise.fill"
        case .dhuhr:   return "sun.max"
        case .asr:     return "sun.max"
        case .maghrib: return "sunset"
        case .isha:    return "moon.stars"
        }
    }

    /// The five obligatory prayers, excluding sunrise.
    static var obligatory: [PrayerName] { [.fajr, .dhuhr, .asr, .maghrib, .isha] }
}

/// A single prayer with the concrete `Date` it occurs at.
struct PrayerTime: Identifiable, Codable, Hashable {
    let prayer: PrayerName
    let date: Date

    var id: String { prayer.rawValue }
}

/// All six timings for a single calendar day.
struct DailyPrayerTimes: Codable, Equatable {
    /// Start of the calendar day these timings belong to.
    let day: Date
    /// Ordered fajr → isha (six entries).
    let times: [PrayerTime]

    /// Look up a specific timing.
    func time(for prayer: PrayerName) -> Date? {
        times.first { $0.prayer == prayer }?.date
    }

    /// Just the five obligatory prayers (used by the widget's bottom row).
    var obligatory: [PrayerTime] {
        times.filter { PrayerName.obligatory.contains($0.prayer) }
    }
}
