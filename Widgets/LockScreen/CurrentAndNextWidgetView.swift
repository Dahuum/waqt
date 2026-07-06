//
//  CurrentAndNextWidgetView.swift
//  SalatWidget — Widget Extension (Lock Screen)
//
//  Style 4 · "Current & Next" (accessoryRectangular).
//  Two columns — NOW and NEXT — each with an icon, prayer name, and time,
//  separated by an arrow.
//

import WidgetKit
import SwiftUI

struct CurrentAndNextWidgetView: View {
    var entry: SalatEntry

    var body: some View {
        HStack(spacing: 6) {
            column(title: "NOW", prayer: entry.currentPrayer)
            Image(systemName: "arrow.right")
                .font(.caption2)
                .foregroundStyle(.secondary)
            column(title: "NEXT", prayer: entry.nextObligatory)
        }
        .lockScreenContainer(background: true)
    }

    private func column(title: String, prayer: PrayerTime?) -> some View {
        VStack(spacing: 1) {
            Text(title)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(.secondary)
            Image(systemName: (prayer?.prayer ?? .fajr).symbolName)
                .font(.footnote)
            Text(prayer?.prayer.displayName ?? "—")
                .font(.caption2).fontWeight(.semibold)
                .minimumScaleFactor(0.7)
            if let prayer {
                Text(prayer.date, style: .time)
                    .font(.caption2).monospacedDigit()
            }
        }
        .frame(maxWidth: .infinity)
    }
}
