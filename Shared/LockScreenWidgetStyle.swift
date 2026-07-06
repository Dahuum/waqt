//
//  LockScreenWidgetStyle.swift
//  SalatWidget — Shared
//
//  Which Lock Screen accessory style to render. Stored in the shared App Group
//  (inside PrayerSettings) and picked in the app's Settings screen. This is
//  separate from `WidgetTheme`, which controls the Home Screen widget.
//
//  Each case names its natural accessory family. When a style is placed in the
//  other family's slot, the widget falls back to a sensible default for that
//  family (see LockScreenRootView) so nothing ever renders blank.
//

import Foundation

enum LockScreenWidgetStyle: String, CaseIterable, Codable, Identifiable {
    case prayerWave        // rectangular
    case ringCountdown     // circular
    case countdownCard     // rectangular
    case currentAndNext    // rectangular
    case allPrayersList    // rectangular
    case currentProgress   // circular
    case compactGrid       // rectangular
    case nextPrayerDetail  // rectangular

    var id: String { rawValue }

    /// The accessory family this style is designed for.
    enum Family { case circular, rectangular }

    var naturalFamily: Family {
        switch self {
        case .ringCountdown, .currentProgress:
            return .circular
        case .prayerWave, .countdownCard, .currentAndNext,
             .allPrayersList, .compactGrid, .nextPrayerDetail:
            return .rectangular
        }
    }

    /// Label shown in the Settings picker, annotated with its family.
    var displayName: String {
        switch self {
        case .prayerWave:       return "Prayer Wave · Rectangular"
        case .ringCountdown:    return "Ring Countdown · Circular"
        case .countdownCard:    return "Countdown Card · Rectangular"
        case .currentAndNext:   return "Current & Next · Rectangular"
        case .allPrayersList:   return "All Prayers List · Rectangular"
        case .currentProgress:  return "Current Progress · Circular"
        case .compactGrid:      return "Compact Grid · Rectangular"
        case .nextPrayerDetail: return "Next Prayer Detail · Rectangular"
        }
    }
}
