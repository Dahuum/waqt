//
//  RingCountdownWidgetView.swift
//  SalatWidget — Widget Extension (Lock Screen)
//
//  Style 2 · "Ring Countdown" (accessoryCircular).
//  A circular capacity Gauge fills as the current window elapses toward the next
//  prayer. The center shows the next prayer's SF Symbol and a live countdown.
//

import WidgetKit
import SwiftUI

struct RingCountdownWidgetView: View {
    var entry: SalatEntry

    var body: some View {
        Gauge(value: entry.windowProgress) {
            EmptyView()
        } currentValueLabel: {
            VStack(spacing: 0) {
                Image(systemName: (entry.nextObligatory?.prayer ?? .fajr).symbolName)
                    .font(.system(size: 9))
                if let next = entry.nextObligatory {
                    Text(next.date, style: .timer)
                        .font(.system(size: 11, weight: .semibold))
                        .monospacedDigit()
                        .minimumScaleFactor(0.5)
                } else {
                    Text("--")
                        .font(.system(size: 11, weight: .semibold))
                }
            }
        }
        .gaugeStyle(.accessoryCircularCapacity)
        .widgetAccentable()
        .lockScreenContainer(background: false)
    }
}
