//
//  SalatWidget.swift
//  SalatWidget — Widget Extension
//
//  Widget configuration: a static (non-configurable) widget wired to the
//  timeline provider, declaring every supported family. The root entry view
//  switches on the stored theme so more styles can be added later.
//

import WidgetKit
import SwiftUI

struct SalatWidget: Widget {
    let kind = "SalatWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SalatTimelineProvider()) { entry in
            SalatWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Salat")
        .description("Next prayer, a live countdown, and today's times.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryRectangular,
            .accessoryCircular
        ])
    }
}

/// Routes to the right view for the current widget family: Lock Screen accessory
/// families use the selected `LockScreenWidgetStyle`; Home Screen families use
/// the selected home-screen `WidgetTheme`.
struct SalatWidgetEntryView: View {
    var entry: SalatEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .accessoryCircular, .accessoryRectangular, .accessoryInline:
            LockScreenRootView(entry: entry)
        default:
            homeScreenView
        }
    }

    @ViewBuilder private var homeScreenView: some View {
        switch entry.theme {
        case .minimalCard:
            MinimalCardWidgetView(entry: entry)
        }
    }
}

// Classic preview provider so previews work on the iOS 16 deployment target
// (the `#Preview(as:widget:timeline:)` macro requires iOS 17).
struct SalatWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MinimalCardWidgetView(entry: .sample)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            MinimalCardWidgetView(entry: .sample)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            MinimalCardWidgetView(entry: .sample)
                .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
        }
    }
}
