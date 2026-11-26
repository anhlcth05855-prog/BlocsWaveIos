import SwiftUI

/// Reusable gradient styling for waveforms, buttons, and glassmorphic cards.
public enum AppGradients {
    public static func waveformGradient(for color: Color) -> LinearGradient {
        LinearGradient(
            colors: [
                color.opacity(0.95),
                color,
                color.opacity(0.7)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    public static func playheadGradient(for color: Color) -> LinearGradient {
        LinearGradient(
            colors: [
                Color.white,
                color,
                Color.white.opacity(0.8)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    public static let backgroundMesh = LinearGradient(
        colors: [
            AppColors.backgroundDark,
            Color(red: 0.06, green: 0.08, blue: 0.13),
            AppColors.backgroundDark
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let glassCard = LinearGradient(
        colors: [
            Color.white.opacity(0.08),
            Color.white.opacity(0.02)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let neonGlow = RadialGradient(
        colors: [
            AppColors.neonCyan.opacity(0.3),
            Color.clear
        ],
        center: .center,
        startRadius: 2,
        endRadius: 50
    )
}
