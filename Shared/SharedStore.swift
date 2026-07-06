//
//  SharedStore.swift
//  SalatWidget — Shared
//
//  Thin wrapper over the App Group `UserDefaults` suite. This is the single
//  channel of communication between the main app (which computes/caches data)
//  and the widget extension (which reads it). No networking, 100% on-device.
//

import Foundation

/// App Group identity, shared by the app and widget entitlements.
enum AppGroup {
    static let identifier = "group.com.dahuum.salatwidget"
}

/// Read/write access to shared prayer settings and cached location.
struct SharedStore {

    /// Shared instance backed by the App Group suite.
    static let shared = SharedStore()

    private let defaults: UserDefaults

    private enum Keys {
        static let settings     = "prayer_settings"
        static let latitude     = "cached_latitude"
        static let longitude    = "cached_longitude"
        static let locationName = "cached_location_name"
    }

    /// Defaults to the App Group suite; falls back to `.standard` if the suite
    /// can't be created (e.g. App Group not yet provisioned in a fresh build).
    init(defaults: UserDefaults? = nil) {
        self.defaults = defaults ?? UserDefaults(suiteName: AppGroup.identifier) ?? .standard
    }

    // MARK: Settings

    var settings: PrayerSettings {
        get {
            guard
                let data = defaults.data(forKey: Keys.settings),
                let decoded = try? JSONDecoder().decode(PrayerSettings.self, from: data)
            else { return PrayerSettings() }
            return decoded
        }
        nonmutating set {
            if let data = try? JSONEncoder().encode(newValue) {
                defaults.set(data, forKey: Keys.settings)
            }
        }
    }

    // MARK: Cached location

    /// Last known coordinates, or `nil` if we've never resolved a location.
    var coordinates: (latitude: Double, longitude: Double)? {
        guard
            defaults.object(forKey: Keys.latitude) != nil,
            defaults.object(forKey: Keys.longitude) != nil
        else { return nil }
        return (defaults.double(forKey: Keys.latitude),
                defaults.double(forKey: Keys.longitude))
    }

    /// A friendly place name for display, defaulting to a generic label.
    var locationName: String {
        defaults.string(forKey: Keys.locationName) ?? "Current Location"
    }

    /// Cache resolved coordinates (and optionally a reverse-geocoded name).
    func setCoordinates(latitude: Double, longitude: Double, name: String?) {
        defaults.set(latitude, forKey: Keys.latitude)
        defaults.set(longitude, forKey: Keys.longitude)
        if let name { defaults.set(name, forKey: Keys.locationName) }
    }
}
