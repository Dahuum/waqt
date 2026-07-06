//
//  NextPrayerDetailWidgetView.swift
//  SalatWidget — Widget Extension (Lock Screen)
//
//  Style 8 · "Next Prayer Detail" (accessoryRectangular).
//  Like the Countdown Card, but the left element is a static clock-face glyph
//  instead of a progress gauge, paired with the next prayer's name, exact time,
//  and remaining time on the right.
//

import WidgetKit
import SwiftUI

struct NextPrayerDetailWidgetView: View {
    var entry: SalatEntry

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "clock")
                .font(.system(size: 30, weight: .light))
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
