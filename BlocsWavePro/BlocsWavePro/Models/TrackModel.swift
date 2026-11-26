import Foundation
import SwiftUI
import AVFoundation

/// Category / Instrument type of a loop track.
public enum TrackType: String, CaseIterable, Codable, Sendable {
    case kick = "Kick & Beats"
    case snare = "Snare & Claps"
    case hihat = "Hi-Hats & Shaker"
    case bass = "Sub & Synth Bass"
    case chords = "Synth Chords"
    case lead = "Lead Melody"
    case pluck = "Acoustic / Pluck"
    case vocalFX = "Vocal Chops & FX"

    public var systemIconName: String {
        switch self {
        case .kick: return "music.note"
        case .snare: return "waveform.badge.plus"
        case .hihat: return "metronome"
        case .bass: return "speaker.wave.3.fill"
        case .chords: return "pianokeys"
        case .lead: return "waveform.path"
        case .pluck: return "guitars.fill"
        case .vocalFX: return "mic.fill"
        }
    }
}

/// Primary model representing an audio track in the 8-track live looper.
public struct TrackModel: Identifiable, Equatable, Sendable {
    public let id: UUID
    public var index: Int
    public var name: String
    public var type: TrackType
    public var colorIndex: Int

    // Audio properties
    public var audioFileURL: URL?
    public var originalBPM: Double
    public var originalKey: MusicalKey
    public var durationSeconds: Double
    public var totalFrames: AVAudioFramePosition

    // Visual Waveform (Normalized decibel peaks between 0.0 and 1.0)
    public var waveformPeaks: [Float]

    // Mixing & Processing
    public var volume: Float
    public var pan: Float
    public var isMuted: Bool
    public var isSolo: Bool
    public var eqSettings: EQSettings
    public var sliceState: SliceState

    // Real-time Playback State
    public var playheadProgress: Double // 0.0 ... 1.0
    public var isLoaded: Bool
    public var isUserRecorded: Bool

    public init(
        id: UUID = UUID(),
        index: Int,
        name: String,
        type: TrackType,
        colorIndex: Int? = nil,
        audioFileURL: URL? = nil,
        originalBPM: Double = 124.0,
        originalKey: MusicalKey = MusicalKey(pitch: .c, mode: .minor),
        durationSeconds: Double = 0.0,
        totalFrames: AVAudioFramePosition = 0,
        waveformPeaks: [Float] = [],
        volume: Float = 0.85,
        pan: Float = 0.0,
        isMuted: Bool = false,
        isSolo: Bool = false,
        eqSettings: EQSettings = .flat,
        sliceState: SliceState = SliceState(),
        playheadProgress: Double = 0.0,
        isLoaded: Bool = false,
        isUserRecorded: Bool = false
    ) {
        self.id = id
        self.index = index
        self.name = name
        self.type = type
        self.colorIndex = colorIndex ?? index
        self.audioFileURL = audioFileURL
        self.originalBPM = originalBPM
        self.originalKey = originalKey
        self.durationSeconds = durationSeconds
        self.totalFrames = totalFrames
        self.waveformPeaks = waveformPeaks
        self.volume = volume
        self.pan = pan
        self.isMuted = isMuted
        self.isSolo = isSolo
        self.eqSettings = eqSettings
        self.sliceState = sliceState
        self.playheadProgress = playheadProgress
        self.isLoaded = isLoaded
        self.isUserRecorded = isUserRecorded
    }

    public var displayColor: Color {
        AppColors.trackColor(for: colorIndex)
    }

    /// Formatted BPM label
    public var bpmDisplay: String {
        String(format: "%.0f BPM", originalBPM)
    }

    /// Default 8 tracks configuration with preset styles
    public static func defaultTrackTemplates() -> [TrackModel] {
        let types: [TrackType] = [
            .kick, .snare, .hihat, .bass,
            .chords, .lead, .pluck, .vocalFX
        ]
        let defaultKeys: [MusicalKey] = [
            MusicalKey(pitch: .c, mode: .minor),
            MusicalKey(pitch: .c, mode: .minor),
            MusicalKey(pitch: .c, mode: .minor),
            MusicalKey(pitch: .c, mode: .minor),
            MusicalKey(pitch: .c, mode: .minor),
            MusicalKey(pitch: .c, mode: .minor),
            MusicalKey(pitch: .c, mode: .minor),
            MusicalKey(pitch: .c, mode: .minor)
        ]

        return types.enumerated().map { index, type in
            TrackModel(
                index: index,
                name: type.rawValue,
                type: type,
                colorIndex: index,
                originalBPM: 124.0,
                originalKey: defaultKeys[index],
                waveformPeaks: generateMockPeaks(count: 64, style: type)
            )
        }
    }

    /// Generates characteristic waveform envelope peaks for initial preview
    public static func generateMockPeaks(count: Int, style: TrackType) -> [Float] {
        var peaks: [Float] = []
        for i in 0..<count {
            let phase = Double(i) / Double(count)
            var val: Float
            switch style {
            case .kick:
                let beat = (phase * 4.0).truncatingRemainder(dividingBy: 1.0)
                val = Float(max(0.1, 0.95 * exp(-beat * 6.0) + 0.15 * sin(phase * 32.0)))
            case .snare:
                let beat = (phase * 2.0).truncatingRemainder(dividingBy: 1.0)
                val = (beat > 0.45 && beat < 0.65) ? Float.random(in: 0.75...1.0) : Float.random(in: 0.05...0.2)
            case .hihat:
                let hat16 = (phase * 16.0).truncatingRemainder(dividingBy: 1.0)
                val = Float(0.2 + 0.6 * exp(-hat16 * 5.0) + Double.random(in: 0.0...0.15))
            case .bass:
                val = Float(0.5 + 0.4 * sin(phase * .pi * 8.0) * cos(phase * .pi * 2.0))
            case .chords:
                val = Float(0.45 + 0.35 * sin(phase * .pi * 4.0) + Double.random(in: 0.0...0.1))
            case .lead:
                val = Float(0.3 + 0.6 * abs(sin(phase * .pi * 12.0)))
            case .pluck:
                let beat8 = (phase * 8.0).truncatingRemainder(dividingBy: 1.0)
                val = Float(0.85 * exp(-beat8 * 4.0) + 0.1)
            case .vocalFX:
                val = Float(0.25 + 0.65 * abs(sin(phase * .pi * 6.0) * cos(phase * .pi * 3.0)))
            }
            peaks.append(min(1.0, max(0.05, val)))
        }
        return peaks
    }
}
