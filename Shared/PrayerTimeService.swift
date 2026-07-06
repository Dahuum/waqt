//
//  PrayerTimeService.swift
//  SalatWidget — Shared
//
//  Wraps the Adhan-swift library to turn (date, coordinates, settings) into
//  concrete prayer `Date`s. Compiled into both targets so the widget can compute
//  times independently without any shared runtime state.
//

import Foundation
import Adhan

enum PrayerTimeService {

    /// Compute the six daily timings for `date` at the given coordinates.
    ///
    /// - Returns: `nil` only for pathological inputs Adhan can't solve
    ///   (e.g. polar day/night where an angle-based prayer never occurs).
    static func dailyTimes(for date: Date,
                           latitude: Double,
                           longitude: Double,
                           settings: PrayerSettings,
                           calendar: Calendar = .current) -> DailyPrayerTimes? {

        let coordinates = Coordinates(latitude: latitude, longitude: longitude)
        let components = calendar.dateComponents([.year, .month, .day], from: date)

        var params = calculationParameters(for: settings)
        params.madhab = settings.useHanafiAsr ? .hanafi : .shafi
        // Per-prayer fine tuning, in minutes. `adjustments` is the public,
        // user-facing offset set (distinct from Adhan's internal method presets).
        params.adjustments = PrayerAdjustments(
            fajr: settings.offsetFajr,
            sunrise: settings.offsetSunrise,
            dhuhr: settings.offsetDhuhr,
            asr: settings.offsetAsr,
            maghrib: settings.offsetMaghrib,
            isha: settings.offsetIsha
        )

        guard let prayers = PrayerTimes(coordinates: coordinates,
                                        date: components,
                                        calculationParameters: params) else {
            return nil
        }

        let times: [PrayerTime] = [
            PrayerTime(prayer: .fajr,    date: prayers.fajr),
            PrayerTime(prayer: .sunrise, date: prayers.sunrise),
            PrayerTime(prayer: .dhuhr,   date: prayers.dhuhr),
            PrayerTime(prayer: .asr,     date: prayers.asr),
            PrayerTime(prayer: .maghrib, date: prayers.maghrib),
            PrayerTime(prayer: .isha,    date: prayers.isha)
        ]

        return DailyPrayerTimes(day: calendar.startOfDay(for: date), times: times)
    }

    /// The next upcoming prayer at/after `reference`, searching forward a few
    /// days so it correctly rolls over to tomorrow's Fajr after Isha.
    static func nextPrayer(after reference: Date,
                           latitude: Double,
                           longitude: Double,
                           settings: PrayerSettings,
                           calendar: Calendar = .current) -> PrayerTime? {

        for dayOffset in 0...2 {
            guard
                let day = calendar.date(byAdding: .day, value: dayOffset, to: reference),
                let daily = dailyTimes(for: day,
                                       latitude: latitude,
                                       longitude: longitude,
                                       settings: settings,
                                       calendar: calendar)
            else { continue }

            if let next = daily.times.first(where: { $0.date > reference }) {
                return next
            }
        }
        return nil
    }

    /// The current obligatory-prayer window around `reference`: the most recent
    /// obligatory prayer at/before `reference` and the next obligatory prayer
    /// after it. Spans day boundaries (e.g. before Fajr → yesterday's Isha; after
    /// Isha → tomorrow's Fajr), so progress rings work across midnight.
    static func obligatoryWindow(at reference: Date,
                                 latitude: Double,
                                 longitude: Double,
                                 settings: PrayerSettings,
                                 calendar: Calendar = .current) -> (current: PrayerTime?, next: PrayerTime?) {
        var all: [PrayerTime] = []
        for dayOffset in -1...1 {
            if let day = calendar.date(byAdding: .day, value: dayOffset, to: reference),
               let daily = dailyTimes(for: day,
                                      latitude: latitude,
                                      longitude: longitude,
                                      settings: settings,
                                      calendar: calendar) {
                all.append(contentsOf: daily.obligatory)
            }
        }
        all.sort { $0.date < $1.date }
        let current = all.last(where: { $0.date <= reference })
        let next = all.first(where: { $0.date > reference })
        return (current, next)
    }

    // MARK: - Method → Adhan parameters

    private static func calculationParameters(for settings: PrayerSettings) -> CalculationParameters {
        switch settings.method {
        case .muslimWorldLeague:
            return CalculationMethod.muslimWorldLeague.params
        case .ummAlQura:
            return CalculationMethod.ummAlQura.params
        case .northAmerica:
            return CalculationMethod.northAmerica.params
        case .egyptian:
            return CalculationMethod.egyptian.params
        case .karachi:
            return CalculationMethod.karachi.params

        case .moroccoHabous:
            // Morocco's Habous ministry publishes angle-based times close to
            // Fajr 19° / Isha 17°. Start from `.other` (zeroed) and set angles.
            var params = CalculationMethod.other.params
            params.fajrAngle = 19.0
            params.ishaAngle = 17.0
            return params

        case .custom:
            var params = CalculationMethod.other.params
            params.fajrAngle = settings.customFajrAngle
            params.ishaAngle = settings.customIshaAngle
            return params
        }
    }
}
