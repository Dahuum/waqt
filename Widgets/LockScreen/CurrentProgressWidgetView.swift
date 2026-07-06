//
//  CurrentProgressWidgetView.swift
//  SalatWidget — Widget Extension (Lock Screen)
//
//  Style 6 · "Current Progress" (accessoryCircular).
//  A circular capacity Gauge showing how much of the CURRENT prayer window has
//  elapsed since the last prayer began. The center shows the current prayer's
//  3-letter abbreviation (e.g. "DHR").
//

import WidgetKit
import SwiftUI

struct CurrentProgressWidgetView: View {
    var entry: SalatEntry

    var body: some View {
        Gauge(value: entry.windowProgress) {
            EmptyView()
        } currentValueLabel: {
            Text(currentAbbreviation)
                .font(.system(size: 13, weight: .semibold))
                .minimumScaleFactor(0.5)
        }
        .gaugeStyle(.accessoryCircularCapacity)
        .widgetAccentable()
        .lockScreenContainer(background: false)
    }

    private var currentAbbreviation: String {
        let prayer = entry.currentPrayer?.prayer ?? entry.nextObligatory?.prayer ?? .fajr
        return prayer.abbreviation
    }
}
