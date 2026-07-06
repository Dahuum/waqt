//
//  PrayerSettings.swift
//  SalatWidget — Shared
//
//  User-configurable settings. Persisted as JSON in the shared App Group so the
//  widget extension reads exactly what the app wrote.
//

import Foundation

/// A calculation method choice, including two custom presets.
enum CalculationMethodOption: String, CaseIterable, Codable, Identifiable {
    case muslimWorldLeague
    case ummAlQura
    case northAmerica      // ISNA
    case egyptian
    case karachi
    case moroccoHabous     // custom preset tuned for Morocco's Habous ministry
    case custom            // fully manual Fajr/Isha angles

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .muslimWorldLeague: return "Muslim World League"
        case .ummAlQura:         return "Umm al-Qura"
        case .northAmerica:      return "ISNA (North America)"
        case .egyptian:          return "Egyptian"
        case .karachi:           return "Karachi"
        case .moroccoHabous:     return "Morocco (Habous)"
        case .custom:            return "Custom"
        }
    }

    /// Whether the manual angle fields apply to this method.
    var usesCustomAngles: Bool { self == .custom }
}

/// Everything the user can configure. `Codable` so we can round-trip it through
/// the shared App Group `UserDefaults`.
struct PrayerSettings: Codable, Equatable {

    // MARK: Calculation

    var method: CalculationMethodOption = .muslimWorldLeague
    /// Hanafi Asr calculation (later shadow length) when true; Shafi otherwise.
    var useHanafiAsr: Bool = false

    /// Manual angle overrides used by `.custom`. Also handy defaults to tweak.
    var customFajrAngle: Double = 18.0
    var customIshaAngle: Double = 17.0

    // MARK: Per-prayer minute offsets (applied to every method)

    var offsetFajr: Int = 0
    var offsetSunrise: Int = 0
    var offsetDhuhr: Int = 0
    var offsetAsr: Int = 0
    var offsetMaghrib: Int = 0
    var offsetIsha: Int = 0

    // MARK: Appearance

    var widgetTheme: WidgetTheme = .minimalCard
    var lockScreenStyle: LockScreenWidgetStyle = .ringCountdown

    // MARK: Notifications

    var notificationsEnabled: Bool = false
    var notifyFajr: Bool = true
    var notifyDhuhr: Bool = true
    var notifyAsr: Bool = true
    var notifyMaghrib: Bool = true
    var notifyIsha: Bool = true

    // MARK: Helpers

    /// Whether a notification should fire for the given prayer (sunrise never).
    func notify(for prayer: PrayerName) -> Bool {
        switch prayer {
        case .fajr:    return notifyFajr
        case .dhuhr:   return notifyDhuhr
        case .asr:     return notifyAsr
        case .maghrib: return notifyMaghrib
        case .isha:    return notifyIsha
        case .sunrise: return false
        }
    }

    /// The minute offset configured for a given prayer.
    func offset(for prayer: PrayerName) -> Int {
        switch prayer {
        case .fajr:    return offsetFajr
        case .sunrise: return offsetSunrise
        case .dhuhr:   return offsetDhuhr
        case .asr:     return offsetAsr
        case .maghrib: return offsetMaghrib
        case .isha:    return offsetIsha
        }
    }
}

// MARK: - Forward/backward-compatible decoding

extension PrayerSettings {
    private enum CodingKeys: String, CodingKey {
        case method, useHanafiAsr, customFajrAngle, customIshaAngle
        case offsetFajr, offsetSunrise, offsetDhuhr, offsetAsr, offsetMaghrib, offsetIsha
        case widgetTheme, lockScreenStyle
        case notificationsEnabled, notifyFajr, notifyDhuhr, notifyAsr, notifyMaghrib, notifyIsha
    }

    /// Lenient decoding: any key missing from previously-stored JSON falls back
    /// to its default. This keeps saved settings valid when new fields are added
    /// (e.g. `lockScreenStyle`) instead of failing the whole decode.
    init(from decoder: Decoder) throws {
        self.init()
        let c = try decoder.container(keyedBy: CodingKeys.self)
        method = try c.decodeIfPresent(CalculationMethodOption.self, forKey: .method) ?? method
        useHanafiAsr = try c.decodeIfPresent(Bool.self, forKey: .useHanafiAsr) ?? useHanafiAsr
        customFajrAngle = try c.decodeIfPresent(Double.self, forKey: .customFajrAngle) ?? customFajrAngle
        customIshaAngle = try c.decodeIfPresent(Double.self, forKey: .customIshaAngle) ?? customIshaAngle
        offsetFajr = try c.decodeIfPresent(Int.self, forKey: .offsetFajr) ?? offsetFajr
        offsetSunrise = try c.decodeIfPresent(Int.self, forKey: .offsetSunrise) ?? offsetSunrise
        offsetDhuhr = try c.decodeIfPresent(Int.self, forKey: .offsetDhuhr) ?? offsetDhuhr
        offsetAsr = try c.decodeIfPresent(Int.self, forKey: .offsetAsr) ?? offsetAsr
        offsetMaghrib = try c.decodeIfPresent(Int.self, forKey: .offsetMaghrib) ?? offsetMaghrib
        offsetIsha = try c.decodeIfPresent(Int.self, forKey: .offsetIsha) ?? offsetIsha
        widgetTheme = try c.decodeIfPresent(WidgetTheme.self, forKey: .widgetTheme) ?? widgetTheme
        lockScreenStyle = try c.decodeIfPresent(LockScreenWidgetStyle.self, forKey: .lockScreenStyle) ?? lockScreenStyle
        notificationsEnabled = try c.decodeIfPresent(Bool.self, forKey: .notificationsEnabled) ?? notificationsEnabled
        notifyFajr = try c.decodeIfPresent(Bool.self, forKey: .notifyFajr) ?? notifyFajr
        notifyDhuhr = try c.decodeIfPresent(Bool.self, forKey: .notifyDhuhr) ?? notifyDhuhr
        notifyAsr = try c.decodeIfPresent(Bool.self, forKey: .notifyAsr) ?? notifyAsr
        notifyMaghrib = try c.decodeIfPresent(Bool.self, forKey: .notifyMaghrib) ?? notifyMaghrib
        notifyIsha = try c.decodeIfPresent(Bool.self, forKey: .notifyIsha) ?? notifyIsha
    }
}
