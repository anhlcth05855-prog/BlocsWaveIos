import Foundation
import SwiftUI

/// Musical genres supported for multi-track procedural sound banks.
public enum SoundGenre: String, CaseIterable, Identifiable, Codable, Sendable {
    case synthwave = "Synthwave 80s"
    case edm = "EDM Club House"
    case trap = "808 Trap & Hip-Hop"
    case lofi = "Lo-Fi Chillout"
    case acoustic = "Acoustic & Funk"

    public var id: String { rawValue }

    public var icon: String {
        switch self {
        case .synthwave: return "🌆"
        case .edm: return "⚡"
        case .trap: return "🔥"
        case .lofi: return "☕"
        case .acoustic: return "🎸"
        }
    }

    public var defaultBPM: Double {
        switch self {
        case .synthwave: return 124.0
        case .edm: return 128.0
        case .trap: return 138.0
        case .lofi: return 85.0
        case .acoustic: return 115.0
        }
    }

    public var accentColor: Color {
        switch self {
        case .synthwave: return AppColors.neonCyan
        case .edm: return AppColors.neonPurple
        case .trap: return AppColors.recordActive
        case .lofi: return AppColors.neonGold
        case .acoustic: return AppColors.neonLime
        }
    }

    public var description: String {
        switch self {
        case .synthwave:
            return "Retro 80s neon electronic drums, Juno pads, and rolling basslines."
        case .edm:
            return "High energy 4-on-the-floor club kicks, donk bass, and festival supersaw leads."
        case .trap:
            return "Hard-hitting 808 booming subs, fast triplet hi-hat rolls, and dark bells."
        case .lofi:
            return "Dusty vinyl boom-bap drums, Rhodes electric piano, and upright jazz bass."
        case .acoustic:
            return "Wood cajon percussion, funky slap bass, brass horns, and melodic kalimba."
        }
    }
}

/// Represents an individual sound loop preset that can be loaded into an audio track.
public struct SoundPreset: Identifiable, Equatable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let genre: SoundGenre
    public let trackType: TrackType
    public let description: String
    public let icon: String

    public init(
        id: String,
        name: String,
        genre: SoundGenre,
        trackType: TrackType,
        description: String,
        icon: String? = nil
    ) {
        self.id = id
        self.name = name
        self.genre = genre
        self.trackType = trackType
        self.description = description
        self.icon = icon ?? genre.icon
    }
}
