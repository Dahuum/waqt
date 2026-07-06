//
//  CountdownCardWidgetView.swift
//  SalatWidget — Widget Extension (Lock Screen)
//
//  Style 3 · "Countdown Card" (accessoryRectangular).
//  Left: a small capacity Gauge (no center text) showing progress to the next
//  prayer. Right: the next prayer's icon + name, exact time, and remaining time.
//

import WidgetKit
import SwiftUI

struct CountdownCardWidgetView: View {
    var entry: SalatEntry

    var body: some View {
        HStack(spacing: 10) {
            Gauge(value: entry.windowProgress) { EmptyView() }
                .gaugeStyle(.accessoryCircularCapacity)
                .frame(width: 34, height: 34)
                .widgetAccentable()

            VStack(alignment: .trailing, spacing: 1) {
                if let next = entry.nextObligatory {
                    HStack(spacing: 3) {
                        Image(systemName: next.prayer.symbolName).font(.caption2)
                        Text(next.prayer.displayName).font(.headline)
                    }
                    Text(next.date, style: .time)
                        .font(.subheadline).monospacedDigit()
                    (Text("in ") + Text(next.date, style: .relative))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                } else {
                    Text("—").font(.headline)
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .lockScreenContainer(background: true)
    }
}
