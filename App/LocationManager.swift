//
//  LocationManager.swift
//  SalatWidget — App
//
//  CoreLocation wrapper. Requests when-in-use permission, resolves the current
//  coordinates once, reverse-geocodes a friendly name, and caches everything to
//  the shared App Group so the widget can compute times on its own.
//

import Foundation
import CoreLocation
import WidgetKit

@MainActor
final class LocationManager: NSObject, ObservableObject {

    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var coordinate: CLLocationCoordinate2D?
    @Published var locationName: String = SharedStore.shared.locationName

    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        authorizationStatus = manager.authorizationStatus

        // Seed from cache so the UI has something before the first fix.
        if let cached = SharedStore.shared.coordinates {
            coordinate = CLLocationCoordinate2D(latitude: cached.latitude,
                                                longitude: cached.longitude)
        }
    }

    /// Ask for permission (no-op if already decided) and request a fresh fix.
    func requestPermission() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        default:
            break
        }
    }

    /// Explicitly request a one-shot location update.
    func refresh() {
        manager.requestLocation()
    }

    private func cache(latitude: Double, longitude: Double) {
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        SharedStore.shared.setCoordinates(latitude: latitude, longitude: longitude, name: nil)
        // The widget can now recompute from the new cached coordinates.
        WidgetCenter.shared.reloadAllTimelines()

        // Best-effort reverse geocode for a nicer display name.
        let location = CLLocation(latitude: latitude, longitude: longitude)
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            guard let self, let place = placemarks?.first else { return }
            let name = place.locality ?? place.administrativeArea ?? place.country ?? "Current Location"
            Task { @MainActor in
                self.locationName = name
                SharedStore.shared.setCoordinates(latitude: latitude, longitude: longitude, name: name)
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }
}

// CLLocationManagerDelegate callbacks arrive on the main thread for a main-actor
// manager; we hop explicitly to satisfy the compiler's isolation checks.
extension LocationManager: CLLocationManagerDelegate {

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            self.authorizationStatus = status
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                self.refresh()
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager,
                                     didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        Task { @MainActor in self.cache(latitude: latitude, longitude: longitude) }
    }

    nonisolated func locationManager(_ manager: CLLocationManager,
                                     didFailWithError error: Error) {
        // Non-fatal: keep whatever we had cached. A retry happens on next launch.
    }
}
