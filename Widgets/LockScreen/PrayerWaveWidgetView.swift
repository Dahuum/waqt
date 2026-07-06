//
//  PrayerWaveWidgetView.swift
//  SalatWidget — Widget Extension (Lock Screen)
//
//  Style 1 · "Prayer Wave" (accessoryRectangular).
//  A smooth curve drawn with Path.addCurve represents the arc of the day, with a
//  dot for each of the five prayers along it: the next prayer's dot is large and
//  filled, past prayers are small and hollow. The next prayer's name + time sit
//  below the curve.
//

import WidgetKit
import SwiftUI

struct PrayerWaveWidgetView: View {
    var entry: SalatEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            wave
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            label
        }
        .lockScreenContainer(background: false)
    }

    // MARK: Label under the curve

    private var label: some View {
        HStack(spacing: 4) {
            Image(systemName: (entry.nextObligatory?.prayer ?? .fajr).symbolName)
                .font(.system(size: 10))
            Text(entry.nextObligatory?.prayer.displayName ?? "—")
                .font(.caption2).fontWeight(.semibold)
            Spacer(minLength: 2)
            if let next = entry.nextObligatory {
                Text(next.date, style: .time)
                    .font(.caption2).monospacedDigit()
            }
        }
    }

    // MARK: The curve + dots

    private var wave: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let count = entry.dayTimes.count
            let n = max(count, 2)
            let inset: CGFloat = 5
            let usableW = w - inset * 2
            let amp = max((h - inset * 2) / 2, 1)
            let midY = h / 2

            // Anchor point for each prayer, evenly spaced, following a gentle arch.
            let points: [CGPoint] = (0..<count).map { i in
                let t = CGFloat(i) / CGFloat(n - 1)
                let x = inset + usableW * t
                let y = midY - amp * sin(t * .pi) * 0.85
                return CGPoint(x: x, y: y)
            }

            ZStack {
                wavePath(points)
                    .stroke(.primary, style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                    .opacity(0.55)
                ForEach(Array(entry.dayTimes.enumerated()), id: \.offset) { idx, pt in
                    dot(for: pt).position(points[idx])
                }
            }
            .widgetAccentable()
        }
    }

    /// Smooth cubic spline through the anchor points (horizontal tangents).
    private func wavePath(_ pts: [CGPoint]) -> Path {
        Path { p in
            guard let first = pts.first else { return }
            p.move(to: first)
            for i in 1..<pts.count {
                let p0 = pts[i - 1], p1 = pts[i]
                let c1 = CGPoint(x: (p0.x + p1.x) / 2, y: p0.y)
                let c2 = CGPoint(x: (p0.x + p1.x) / 2, y: p1.y)
                p.addCurve(to: p1, control1: c1, control2: c2)
            }
        }
    }

    @ViewBuilder private func dot(for pt: PrayerTime) -> some View {
        if pt.prayer == entry.nextObligatory?.prayer {
            Circle().fill(.primary).frame(width: 8, height: 8)          // next: large filled
        } else if pt.date < entry.date {
            Circle().strokeBorder(.primary, lineWidth: 1)               // past: hollow
                .frame(width: 5, height: 5).opacity(0.7)
        } else {
            Circle().fill(.primary).frame(width: 5, height: 5).opacity(0.85) // upcoming
        }
    }
}
