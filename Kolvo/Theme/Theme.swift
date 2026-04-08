//
//  Theme.swift
//  Kolvo
//

import SwiftUI

enum Theme {
    // Backgrounds
    static let background = Color(red: 0.98, green: 0.97, blue: 0.95) // Warm off-white
    static let cardBackground = Color(red: 0.96, green: 0.94, blue: 0.91) // Soft cream
    static let cardBackgroundPressed = Color(red: 0.93, green: 0.91, blue: 0.88)

    // Text
    static let textPrimary = Color(red: 0.25, green: 0.23, blue: 0.21) // Warm dark brown
    static let textSecondary = Color(red: 0.45, green: 0.42, blue: 0.39) // Muted brown
    static let textTertiary = Color(red: 0.62, green: 0.59, blue: 0.55) // Light brown

    // Accents
    static let accent = Color(red: 0.55, green: 0.50, blue: 0.45) // Warm gray-brown
    static let accentSoft = Color(red: 0.70, green: 0.66, blue: 0.61) // Lighter accent

    // Button
    static let buttonBackground = Color(red: 0.35, green: 0.32, blue: 0.29) // Dark warm gray
    static let buttonForeground = Color(red: 0.98, green: 0.97, blue: 0.95) // Matches background

    // Destructive (kept muted)
    static let destructive = Color(red: 0.72, green: 0.45, blue: 0.42) // Muted terracotta

    // Animations
    static let gentleSpring = Animation.spring(response: 0.4, dampingFraction: 0.75)
    static let softSpring = Animation.spring(response: 0.5, dampingFraction: 0.8)
    static let quickSpring = Animation.spring(response: 0.3, dampingFraction: 0.7)
}
