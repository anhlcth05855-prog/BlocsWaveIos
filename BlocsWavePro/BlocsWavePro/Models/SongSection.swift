import Foundation
import SwiftUI

/// Section ID representing A, B, C, D
public enum SectionID: String, CaseIterable, Codable, Sendable {
    case a = "A"
    case b = "B"
    case c = "C"
    case d = "D"

    public var defaultName: String {
        switch self {
        case .a: return "Intro"
        case .b: return "Verse"
        case .c: return "Chorus"
        case .d: return "Outro"
        }
    }

    public var accentColor: Color {
        switch self {
        case .a: return AppColors.neonCyan
        case .b: return AppColors.neonMagenta
        case .c: return AppColors.neonPurple
        case .d: return AppColors.neonGold
        }
    }
}

/// Snapshot of a single track's state in a specific song section.
public struct TrackSectionSnapshot: Codable, Equatable, Sendable {
    public var isMuted: Bool
    public var volume: Float

    public init(isMuted: Bool = false, volume: Float = 0.85) {
        self.isMuted = isMuted
        self.volume = volume
    }
}

/// Represents one song section containing snapshots for all 8 tracks.
public struct SongSection: Identifiable, Codable, Equatable, Sendable {
    public var id: SectionID
    public var name: String
    /// Dictionary of [trackIndex: Snapshot]
    public var trackSnapshots: [Int: TrackSectionSnapshot]

    public init(
        id: SectionID,
        name: String? = nil,
        trackSnapshots: [Int: TrackSectionSnapshot] = [:]
    ) {
        self.id = id
        self.name = name ?? id.defaultName
        self.trackSnapshots = trackSnapshots
    }

    public static let defaultSections: [SongSection] = [
        // Section A (Intro): Kick, Hats, Chords active; Snare, Lead, Bass muted
        SongSection(id: .a, name: "Intro", trackSnapshots: [
            0: TrackSectionSnapshot(isMuted: false, volume: 0.85),
            1: TrackSectionSnapshot(isMuted: true, volume: 0.85),
            2: TrackSectionSnapshot(isMuted: false, volume: 0.75),
            3: TrackSectionSnapshot(isMuted: true, volume: 0.85),
            4: TrackSectionSnapshot(isMuted: false, volume: 0.80),
            5: TrackSectionSnapshot(isMuted: true, volume: 0.80),
            6: TrackSectionSnapshot(isMuted: true, volume: 0.80),
            7: TrackSectionSnapshot(isMuted: false, volume: 0.70)
        ]),
        // Section B (Verse): Drums, Bass, Chords
        SongSection(id: .b, name: "Verse", trackSnapshots: [
            0: TrackSectionSnapshot(isMuted: false, volume: 0.85),
            1: TrackSectionSnapshot(isMuted: false, volume: 0.85),
            2: TrackSectionSnapshot(isMuted: false, volume: 0.75),
            3: TrackSectionSnapshot(isMuted: false, volume: 0.85),
            4: TrackSectionSnapshot(isMuted: false, volume: 0.80),
            5: TrackSectionSnapshot(isMuted: true, volume: 0.80),
            6: TrackSectionSnapshot(isMuted: false, volume: 0.80),
            7: TrackSectionSnapshot(isMuted: true, volume: 0.70)
        ]),
        // Section C (Chorus): All tracks active, high energy
        SongSection(id: .c, name: "Chorus", trackSnapshots: [
            0: TrackSectionSnapshot(isMuted: false, volume: 0.90),
            1: TrackSectionSnapshot(isMuted: false, volume: 0.90),
            2: TrackSectionSnapshot(isMuted: false, volume: 0.80),
            3: TrackSectionSnapshot(isMuted: false, volume: 0.90),
            4: TrackSectionSnapshot(isMuted: false, volume: 0.85),
            5: TrackSectionSnapshot(isMuted: false, volume: 0.85),
            6: TrackSectionSnapshot(isMuted: false, volume: 0.85),
            7: TrackSectionSnapshot(isMuted: false, volume: 0.80)
        ]),
        // Section D (Outro): Kick, Chords, Vocal FX fade
        SongSection(id: .d, name: "Outro", trackSnapshots: [
            0: TrackSectionSnapshot(isMuted: false, volume: 0.75),
            1: TrackSectionSnapshot(isMuted: true, volume: 0.85),
            2: TrackSectionSnapshot(isMuted: true, volume: 0.75),
            3: TrackSectionSnapshot(isMuted: true, volume: 0.85),
            4: TrackSectionSnapshot(isMuted: false, volume: 0.70),
            5: TrackSectionSnapshot(isMuted: true, volume: 0.80),
            6: TrackSectionSnapshot(isMuted: true, volume: 0.80),
            7: TrackSectionSnapshot(isMuted: false, volume: 0.85)
        ])
    ]
}
