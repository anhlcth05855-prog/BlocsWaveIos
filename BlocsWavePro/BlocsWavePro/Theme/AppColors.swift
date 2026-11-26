import SwiftUI

/// Defines the neon-infused color palette inspired by professional audio hardware and Blocs Wave.
public enum AppColors {
    // Primary Neon Accents
    public static let neonCyan = Color(red: 0.0, green: 0.94, blue: 1.0)       // #00F0FF
    public static let neonMagenta = Color(red: 1.0, green: 0.05, blue: 0.55)    // #FF0D8D
    public static let neonPurple = Color(red: 0.65, green: 0.15, blue: 1.0)     // #A626FF
    public static let neonGold = Color(red: 1.0, green: 0.84, blue: 0.0)        // #FFD700
    public static let neonLime = Color(red: 0.22, green: 1.0, blue: 0.08)       // #38FF15
    public static let neonOrange = Color(red: 1.0, green: 0.45, blue: 0.0)      // #FF7300
    public static let neonRose = Color(red: 1.0, green: 0.2, blue: 0.4)         // #FF3366
    public static let electricBlue = Color(red: 0.1, green: 0.45, blue: 1.0)    // #1A73FF

    // Dark Sleek Backgrounds
    public static let backgroundDark = Color(red: 0.05, green: 0.06, blue: 0.09)  // #0D0F17
    public static let surfaceDark = Color(red: 0.09, green: 0.10, blue: 0.15)     // #171A26
    public static let surfaceCard = Color(red: 0.13, green: 0.15, blue: 0.22)     // #212638
    public static let surfaceCardBorder = Color.white.opacity(0.10)
    public static let surfaceElevated = Color(red: 0.16, green: 0.18, blue: 0.27)

    // Functional State Colors
    public static let playActive = Color(red: 0.0, green: 0.94, blue: 0.45)
    public static let recordActive = Color(red: 1.0, green: 0.15, blue: 0.15)
    public static let soloYellow = Color(red: 1.0, green: 0.85, blue: 0.1)
    public static let muteRed = Color(red: 0.95, green: 0.25, blue: 0.25)
    public static let metronomeTick = Color(red: 0.3, green: 0.85, blue: 1.0)

    // Text & Controls
    public static let textPrimary = Color.white
    public static let textSecondary = Color(white: 0.68)
    public static let textMuted = Color(white: 0.45)

    /// Dynamic Track Palette for 8 tracks
    public static let trackColors: [Color] = [
        neonCyan,       // Track 1: Kick
        neonMagenta,    // Track 2: Snare
        neonPurple,     // Track 3: Hats
        neonGold,       // Track 4: Bass
        neonLime,       // Track 5: Chords
        electricBlue,   // Track 6: Lead
        neonOrange,     // Track 7: Pluck
        neonRose        // Track 8: Vocal / FX
    ]

    public static func trackColor(for index: Int) -> Color {
        trackColors[index % trackColors.count]
    }
}
