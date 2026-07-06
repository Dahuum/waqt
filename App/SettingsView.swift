//
//  SettingsView.swift
//  SalatWidget — App
//
//  Calculation method, manual angle/offset tuning, widget theme, and per-prayer
//  notification toggles. Writes straight into the bound `PrayerSettings`, which
//  ContentView persists to the shared store and mirrors to the widget.
//

import SwiftUI

struct SettingsView: View {

    @Binding var settings: PrayerSettings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                calculationSection
                if settings.method.usesCustomAngles || settings.method == .moroccoHabous {
                    anglesSection
                }
                offsetsSection
                appearanceSection
                notificationsSection
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    // MARK: Sections

    private var calculationSection: some View {
        Section("Calculation Method") {
            Picker("Method", selection: $settings.method) {
                ForEach(CalculationMethodOption.allCases) { method in
                    Text(method.displayName).tag(method)
                }
            }
            Toggle("Hanafi Asr", isOn: $settings.useHanafiAsr)
        }
    }

    private var anglesSection: some View {
        Section {
            angleField("Fajr angle", value: $settings.customFajrAngle)
            angleField("Isha angle", value: $settings.customIshaAngle)
        } header: {
            Text("Custom Angles")
        } footer: {
            Text("Twilight angles in degrees below the horizon. Only used by the Custom method; the Habous preset seeds 19° / 17°.")
        }
    }

    private var offsetsSection: some View {
        Section {
            offsetStepper("Fajr", value: $settings.offsetFajr)
            offsetStepper("Sunrise", value: $settings.offsetSunrise)
            offsetStepper("Dhuhr", value: $settings.offsetDhuhr)
            offsetStepper("Asr", value: $settings.offsetAsr)
            offsetStepper("Maghrib", value: $settings.offsetMaghrib)
            offsetStepper("Isha", value: $settings.offsetIsha)
        } header: {
            Text("Manual Offsets")
        } footer: {
            Text("Minutes added to (or subtracted from) each computed time.")
        }
    }

    private var appearanceSection: some View {
        Section {
            Picker("Home Screen Style", selection: $settings.widgetTheme) {
                ForEach(WidgetTheme.allCases) { theme in
                    Text(theme.displayName).tag(theme)
                }
            }
            Picker("Lock Screen Style", selection: $settings.lockScreenStyle) {
                ForEach(LockScreenWidgetStyle.allCases) { style in
                    Text(style.displayName).tag(style)
                }
            }
        } header: {
            Text("Widgets")
        } footer: {
            Text("Lock Screen styles are grouped by family — pick a Circular style for a circular widget, or a Rectangular style for a rectangular one.")
        }
    }

    private var notificationsSection: some View {
        Section("Notifications") {
            Toggle("Enable notifications", isOn: $settings.notificationsEnabled)
            if settings.notificationsEnabled {
                Toggle("Fajr", isOn: $settings.notifyFajr)
                Toggle("Dhuhr", isOn: $settings.notifyDhuhr)
                Toggle("Asr", isOn: $settings.notifyAsr)
                Toggle("Maghrib", isOn: $settings.notifyMaghrib)
                Toggle("Isha", isOn: $settings.notifyIsha)
            }
        }
    }

    // MARK: Small controls

    private func angleField(_ title: String, value: Binding<Double>) -> some View {
        HStack {
            Text(title)
            Spacer()
            TextField(title, value: value, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 80)
            Text("°").foregroundStyle(.secondary)
        }
    }

    private func offsetStepper(_ title: String, value: Binding<Int>) -> some View {
        Stepper(value: value, in: -30...30) {
            HStack {
                Text(title)
                Spacer()
                Text("\(value.wrappedValue > 0 ? "+" : "")\(value.wrappedValue) min")
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
        }
    }
}

#Preview {
    SettingsView(settings: .constant(PrayerSettings()))
}
