//
//  LockScreenSupport.swift
//  SalatWidget — Widget Extension (Lock Screen)
//
//  Shared plumbing for the Lock Screen accessory styles: the family/style
//  router, the no-location placeholder, a container-background helper that works
//  on both iOS 16 and 17, and small computed values derived from a SalatEntry.
//
//  Lock Screen widgets are rendered by the system in a single desaturated tint,
//  so every style below is designed in monochrome/linework and uses
//  `.widgetAccentable()` to lift key elements into the accent group.
//

import WidgetKit
import SwiftUI

// MARK: - Derived values

extension SalatEntry {
    /// Elapsed fraction (0...1) of the current obligatory-prayer window.
    /// 0 = the last prayer just began, 1 = the next prayer is imminent.
    var windowProgress: Double {
        guard let start = currentPrayer?.date,
              let end = nextObligatory?.date,
              end > start else { return 0 }
        let fraction = date.timeIntervalSince(start) / end.timeIntervalSince(start)
        return min(max(fraction, 0), 1)
    }
}

// MARK: - Router

/// Picks the concrete Lock Screen view based on the widget family and the user's
/// selected `LockScreenWidgetStyle`. If a style is placed in the other family's
/// slot, it falls back to a sensible default for that family so it never renders
/// blank.
struct LockScreenRootView: View {
    var entry: SalatEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        if entry.hasLocation {
            switch family {
            case .accessoryCircular: circular
            default:                 rectangular
            }
        } else {
            LockScreenPlaceholderView()
        }
    }

    @ViewBuilder private var circular: some View {
        switch entry.lockScreenStyle {
        case .currentProgress: CurrentProgressWidgetView(entry: entry)
        default:               RingCountdownWidgetView(entry: entry)
        }
    }

    @ViewBuilder private var rectangular: some View {
        switch entry.lockScreenStyle {
        case .prayerWave:       PrayerWaveWidgetView(entry: entry)
        case .countdownCard:    CountdownCardWidgetView(entry: entry)
        case .currentAndNext:   CurrentAndNextWidgetView(entry: entry)
        case .allPrayersList:   AllPrayersListWidgetView(entry: entry)
        case .compactGrid:      CompactGridWidgetView(entry: entry)
        case .nextPrayerDetail: NextPrayerDetailWidgetView(entry: entry)
        // Circular-only styles placed in a rectangular slot → default rectangular.
        case .ringCountdown, .currentProgress:
            CountdownCardWidgetView(entry: entry)
        }
    }
}

// MARK: - Placeholder

/// Shown when the app hasn't cached a location yet.
struct LockScreenPlaceholderView: View {
    @Environment(\.widgetFamily) private var family

    var body: some View {
        Group {
            if family == .accessoryCircular {
                Image(systemName: "location.slash")
                    .font(.headline)
            } else {
                HStack(spacing: 6) {
                    Image(systemName: "location.slash")
                    Text("Open Salat to set location")
                        .font(.caption2)
                        .minimumScaleFactor(0.7)
                }
            }
        }
        .lockScreenContainer(background: family != .accessoryCircular)
    }
}

// MARK: - Container background (iOS 16 & 17 compatible)

extension View {
    /// Applies the widget container background required on iOS 17 while remaining
    /// valid on iOS 16. Pass `background: true` to show the subtle
    /// `AccessoryWidgetBackground()` behind rectangular "card" styles.
    @ViewBuilder
    func lockScreenContainer(background: Bool) -> some View {
        if #available(iOS 17.0, *) {
            self.containerBackground(for: .widget) {
                if background { AccessoryWidgetBackground() }
            }
        } else if background {
            self.background(AccessoryWidgetBackground())
        } else {
            self
        }
    }
}
