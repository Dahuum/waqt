# SalatWidget

A free, fully open-source iOS prayer-times (Salat) app with Home Screen and
Lock Screen widgets. Everything runs **100% on-device** — no backend, no API
keys, no analytics, no ads. The only dependency is
[Adhan-swift](https://github.com/batoulapps/adhan-swift) (MIT).

Built and verified against **Xcode 26**, deploying to **iOS 16+**.

## Open & run

1. Open `SalatWidget.xcodeproj` in Xcode. Swift Package Manager resolves
   Adhan-swift automatically on first open (needs network once).
2. Select a **Development Team** for both targets so Xcode can sign them:
   - Select the project → **SalatWidget** target → *Signing & Capabilities* → pick your Team.
   - Repeat for the **SalatWidgetExtension** target.
   - Both targets already declare the App Group `group.com.dahuum.salatwidget`.
     If your account can't use that exact group, change it in **both**
     `.entitlements` files and in `AppGroup.identifier` (`Shared/SharedStore.swift`).
3. Run the **SalatWidget** scheme on a simulator or device. Grant location when
   prompted. Then long-press the Home/Lock Screen → **Add Widget** → *Salat*.

> Simulator note: to build without signing (e.g. from the command line) use
> `xcodebuild -scheme SalatWidget -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO`.

## Project layout

```
App/        Main SwiftUI app (entry point, screens, location, notifications)
Widgets/    WidgetKit extension (timeline provider + widget views)
Shared/     Code compiled into BOTH targets (prayer math, models, shared store)
Resources/  Asset catalog + placeholder adhan sound
```

| File | Role |
|------|------|
| `Shared/PrayerTimeService.swift` | Wraps Adhan-swift: (date, coords, settings) → prayer times |
| `Shared/SharedStore.swift` | App Group `UserDefaults` bridge (settings + cached location) |
| `Shared/PrayerSettings.swift` | Codable settings: method, angles, offsets, theme, notifications |
| `Shared/PrayerModels.swift` | `PrayerName`, `PrayerTime`, `DailyPrayerTimes` |
| `App/LocationManager.swift` | CoreLocation (when-in-use), caches coords, reloads widgets |
| `App/NotificationManager.swift` | Per-prayer local notifications with a custom adhan sound |
| `App/ContentView.swift` / `SettingsView.swift` | Main screen + settings sheet |
| `Widgets/Provider.swift` | Timeline: one entry per prayer transition, rolls into tomorrow |
| `Widgets/MinimalCardWidgetView.swift` | The default "Minimal Card" style for every family |
| `Widgets/SalatWidget.swift` | Widget config + supported families + theme routing |

## Calculation methods

Muslim World League, Umm al-Qura, ISNA (North America), Egyptian, Karachi, plus
two custom presets:

- **Morocco (Habous)** — seeds Fajr 19° / Isha 17°.
- **Custom** — set your own Fajr/Isha angles in Settings.

All methods also support per-prayer minute offsets and Hanafi/Shafi Asr.

## Widgets

One default style, **Minimal Card**, rendered for every family:
`systemSmall`, `systemMedium`, `systemLarge`, and the Lock Screen
`accessoryRectangular` / `accessoryCircular`. It shows the next prayer, a live
countdown, and a row of the day's five prayers with completed ones dimmed.

Add more styles as sibling views next to `MinimalCardWidgetView` and switch on
`entry.theme` inside `SalatWidgetEntryView` (`Widgets/SalatWidget.swift`).
The theme is stored in shared settings and picked in the app's Settings screen.

## The adhan sound

`Resources/adhan.caf` is a **placeholder text file**. Replace it with a real
short clip (CAF/AIFF/WAV, < 30 s) keeping the same filename, or update the
reference in `NotificationManager.swift`. Until then iOS uses the default sound.

## Bundle identifiers

- App: `com.dahuum.salatwidget`
- Widget: `com.dahuum.salatwidget.widget`
- App Group: `group.com.dahuum.salatwidget`
