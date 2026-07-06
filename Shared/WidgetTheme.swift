//
//  WidgetTheme.swift
//  SalatWidget — Shared
//
//  The widget visual style, stored in shared UserDefaults so both the settings
//  screen and the widget agree on which style to render. New styles can be added
//  here and wired up as sibling SwiftUI views in the widget extension.
//

import Foundation

enum WidgetTheme: String, CaseIterable, Codable, Identifiable {
    /// Clean card with the next prayer, a live countdown, and a row of all times.
    case minimalCard

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .minimalCard: return "Minimal Card"
        }
    }
}
