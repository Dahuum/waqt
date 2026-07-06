//
//  MinimalCardWidgetView.swift
//  SalatWidget — Widget Extension
//
//  The default "Minimal Card" style. A single standalone SwiftUI view that
//  renders every supported family. Add new styles as sibling views and switch
//  on `entry.theme` in SalatWidgetEntryView.
//

import WidgetKit
import SwiftUI

struct MinimalCardWidgetView: View {

    var entry: SalatEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        content
            .widgetBackground(backgroundColor)
    }

    // MARK: Background (adapts to light/dark; clear on the Lock Screen)

    private var backgroundColor: Color {
        switch family {
        case .accessoryRectangular, .accessoryCircular, .accessoryInline:
            return .clear
        default:
            return Color(.systemBackground)
        }
    }

    // MARK: Family routing

    @ViewBuilder private var content: some View {
        if !entry.hasLocation {
            noLocationView
        } else {
            switch family {
            case .systemSmall:          smallView
            case .systemMedium:         mediumView
            case .systemLarge:          largeView
            case .accessoryRectangular: rectangularView
            case .accessoryCircular:    circularView
            default:                    smallView
            }
        }
    }

    // MARK: Home Screen — Small

    private var smallView: some View {
        VStack(alignment: .leading, spacing: 6) {
            nextPrayerBlock(nameFont: .headline, timerFont: .title2)
            Spacer(minLength: 0)
            prayerRow(compact: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    // MARK: Home Screen — Medium

    private var mediumView: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                nextPrayerBlock(nameFont: .title3, timerFont: .largeTitle)
                Spacer()
                Text(entry.locationName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
            prayerRow(compact: false)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    // MARK: Home Screen — Large

    private var largeView: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                nextPrayerBlock(nameFont: .title2, timerFont: .system(size: 44, weight: .semibold, design: .rounded))
                Spacer()
                Text(entry.locationName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Divider()
            VStack(spacing: 10) {
                ForEach(entry.dayTimes) { pt in
                    HStack {
                        Text(pt.prayer.displayName)
                            .fontWeight(isNext(pt) ? .semibold : .regular)
                        Spacer()
                        Text(pt.date, style: .time)
                            .monospacedDigit()
                    }
                    .foregroundStyle(isCompleted(pt) ? .tertiary : .primary)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(18)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    // MARK: Lock Screen — Rectangular

    private var rectangularView: some View {
        HStack(spacing: 8) {
            Image(systemName: "moon.stars.fill")
                .font(.title3)
            VStack(alignment: .leading, spacing: 1) {
                Text(entry.nextPrayer?.prayer.displayName ?? "—")
                    .font(.headline)
                if let next = entry.nextPrayer {
                    Text(next.date, style: .timer)
                        .font(.caption)
                        .monospacedDigit()
                }
            }
        }
        .widgetAccentable()
    }

    // MARK: Lock Screen — Circular

    private var circularView: some View {
        VStack(spacing: 1) {
            Text(entry.nextPrayer?.prayer.shortName ?? "—")
                .font(.caption2)
            if let next = entry.nextPrayer {
                Text(next.date, style: .time)
                    .font(.caption)
                    .monospacedDigit()
            }
        }
        .widgetAccentable()
    }

    // MARK: Shared pieces

    /// "Next: Asr" + a live countdown timer.
    private func nextPrayerBlock(nameFont: Font, timerFont: Font) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(entry.nextPrayer?.prayer.displayName ?? "—")
                .font(nameFont)
                .fontWeight(.semibold)
            if let next = entry.nextPrayer {
                Text(next.date, style: .timer)
                    .font(timerFont)
                    .monospacedDigit()
                    .foregroundStyle(.primary)
            }
        }
    }

    /// Bottom row of the five prayers; completed ones are dimmed.
    private func prayerRow(compact: Bool) -> some View {
        HStack(spacing: compact ? 4 : 10) {
            ForEach(entry.dayTimes) { pt in
                VStack(spacing: 1) {
                    Text(pt.prayer.displayName)
                        .font(compact ? .system(size: 9) : .caption2)
                    Text(pt.date, style: .time)
                        .font(compact ? .system(size: 9, weight: .medium) : .caption2)
                        .monospacedDigit()
                }
                .foregroundStyle(isCompleted(pt) ? .tertiary : .primary)
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var noLocationView: some View {
        VStack(spacing: 4) {
            Image(systemName: "location.slash")
                .font(.title3)
                .foregroundStyle(.secondary)
            Text("Open Salat")
                .font(.caption).fontWeight(.medium)
            Text("to set your location")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: Helpers

    private func isCompleted(_ pt: PrayerTime) -> Bool { pt.date < entry.date }
    private func isNext(_ pt: PrayerTime) -> Bool { pt.prayer == entry.nextPrayer?.prayer }
}

// MARK: - iOS 16/17 background compatibility

extension View {
    /// `containerBackground` is iOS 17+. On iOS 16 we fall back to a plain
    /// background so the same view compiles and renders on both.
    @ViewBuilder
    func widgetBackground(_ color: Color) -> some View {
        if #available(iOS 17.0, *) {
            containerBackground(color, for: .widget)
        } else {
            background(color)
        }
    }
}
