//
//  AllPrayersListWidgetView.swift
//  SalatWidget — Widget Extension (Lock Screen)
//
//  Style 5 · "All Prayers List" (accessoryRectangular).
//  A compact vertical list of all five prayers with icons and right-aligned
//  times. The next prayer's row is emphasized. Fonts are tuned small with
//  minimumScaleFactor so all five rows fit the ~76pt height.
//

import WidgetKit
import SwiftUI

struct AllPrayersListWidgetView: View {
    var entry: SalatEntry

    var body: some View {
        VStack(spacing: 1) {
            ForEach(entry.dayTimes) { pt in
                HStack(spacing: 5) {
                    Image(systemName: pt.prayer.symbolName)
                        .font(.system(size: 9))
                        .frame(width: 12)
                    Text(pt.prayer.displayName)
                        .font(.system(size: 11))
                    Spacer(minLength: 2)
                    Text(pt.date, style: .time)
                        .font(.system(size: 11))
                        .monospacedDigit()
                }
                .fontWeight(isHighlighted(pt) ? .bold : .regular)
                .foregroundStyle(isHighlighted(pt) ? .primary : .secondary)
            }
        }
        .minimumScaleFactor(0.7)
        .lockScreenContainer(background: true)
    }

    private func isHighlighted(_ pt: PrayerTime) -> Bool {
        pt.prayer == entry.nextObligatory?.prayer
    }
}
