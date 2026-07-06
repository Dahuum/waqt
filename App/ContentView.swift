//
//  ContentView.swift
//  SalatWidget — App
//
//  Main screen: shows the next prayer with a live countdown and today's full
//  schedule. Location is resolved via LocationManager; settings live in a sheet.
//

import SwiftUI
import WidgetKit

struct ContentView: View {

    @StateObject private var location = LocationManager()
    @State private var settings = SharedStore.shared.settings
    @State private var today: DailyPrayerTimes?
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            Group {
                if location.coordinate == nil {
                    locationPrompt
                } else if let today {
                    schedule(today)
                } else {
                    ProgressView("Calculating…")
                }
            }
            .navigationTitle("Salat")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(settings: $settings)
            }
        }
        .onAppear {
            location.requestPermission()
            recompute()
            Task { await NotificationManager.shared.requestAuthorization() }
        }
        // Recompute whenever a new fix arrives or settings change.
        .onReceive(location.$coordinate) { _ in recompute() }
        .onChange(of: settings) { _ in
            SharedStore.shared.settings = settings
            recompute()
            WidgetCenter.shared.reloadAllTimelines()
            if let c = location.coordinate {
                NotificationManager.shared.reschedule(using: settings,
                                                      latitude: c.latitude,
                                                      longitude: c.longitude)
            }
        }
    }

    // MARK: Subviews

    private var locationPrompt: some View {
        ContentUnavailableCompat(
            title: "Location needed",
            systemImage: "location.slash",
            message: "Allow location access to calculate your prayer times."
        ) {
            Button("Allow Location") { location.requestPermission() }
                .buttonStyle(.borderedProminent)
        }
    }

    private func schedule(_ daily: DailyPrayerTimes) -> some View {
        List {
            Section {
                nextPrayerHeader
            }
            Section("Today — \(location.locationName)") {
                ForEach(daily.times) { pt in
                    HStack {
                        Text(pt.prayer.displayName)
                            .fontWeight(pt.prayer == nextPrayer?.prayer ? .semibold : .regular)
                        Spacer()
                        Text(pt.date, style: .time)
                            .foregroundStyle(pt.date < Date() ? .secondary : .primary)
                            .monospacedDigit()
                    }
                }
            }
        }
    }

    @ViewBuilder private var nextPrayerHeader: some View {
        if let next = nextPrayer {
            VStack(alignment: .leading, spacing: 4) {
                Text("Next: \(next.prayer.displayName)")
                    .font(.title2).fontWeight(.semibold)
                Text(next.date, style: .timer)
                    .font(.largeTitle).monospacedDigit()
                    .foregroundStyle(.tint)
            }
            .padding(.vertical, 4)
        }
    }

    private var nextPrayer: PrayerTime? {
        guard let c = location.coordinate else { return nil }
        return PrayerTimeService.nextPrayer(after: Date(),
                                            latitude: c.latitude,
                                            longitude: c.longitude,
                                            settings: settings)
    }

    private func recompute() {
        guard let c = location.coordinate else { today = nil; return }
        today = PrayerTimeService.dailyTimes(for: Date(),
                                             latitude: c.latitude,
                                             longitude: c.longitude,
                                             settings: settings)
    }
}

/// Small compatibility shim so we get a nice empty state on iOS 16
/// (ContentUnavailableView is iOS 17+).
private struct ContentUnavailableCompat<Actions: View>: View {
    let title: String
    let systemImage: String
    let message: String
    @ViewBuilder var actions: () -> Actions

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text(title).font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            actions()
                .padding(.top, 4)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
