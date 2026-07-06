//
//  CompactGridWidgetView.swift
//  SalatWidget — Widget Extension (Lock Screen)
//
//  Style 7 · "Compact Grid Overview" (accessoryRectangular).
//  All five prayers in a two-column grid (three rows). The current prayer's cell
//  is emphasized with a larger, bolder treatment than the rest.
//

import WidgetKit
import SwiftUI

struct CompactGridWidgetView: View {
    var entry: SalatEntry

    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 2) {
            ForEach(rows.indices, id: \.self) { r in
                GridRow {
                    ForEach(rows[r]) { pt in cell(pt) }
                    if rows[r].count == 1 { Color.clear }
                }
            }
        }
        .lockScreenContainer(background: true)
    }

    /// The five prayers chunked into rows of two.
    private var rows: [[PrayerTime]] {
        stride(from: 0, to: entry.dayTimes.count, by: 2).map {
            Array(entry.dayTimes[$0..<min($0 + 2, entry.dayTimes.count)])
        }
    }

    private func isCurrent(_ pt: PrayerTime) -> Bool {
        pt.prayer == (entry.currentPrayer?.prayer ?? entry.nextObligatory?.prayer)
    }

    private func cell(_ pt: PrayerTime) -> some View {
        let current = isCurrent(pt)
        return HStack(spacing: 3) {
            Image(systemName: pt.prayer.symbolName)
                .font(.system(size: current ? 11 : 9))
            VStack(alignment: .leading, spacing: 0) {
                Text(pt.prayer.abbreviation)
                    .font(.system(size: current ? 11 : 9, weight: current ? .bold : .regular))
                Text(pt.date, style: .time)
                    .font(.system(size: current ? 10 : 8))
                    .monospacedDigit()
            }
        }
        .foregroundStyle(current ? .primary : .secondary)
    }
}
