import Foundation

/// Represents the 12 chromatic pitches.
public enum PitchClass: Int, CaseIterable, Codable, Sendable {
    case c = 0
    case cSharp = 1
    case d = 2
    case dSharp = 3
    case e = 4
    case f = 5
    case fSharp = 6
    case g = 7
    case gSharp = 8
    case a = 9
    case aSharp = 10
    case b = 11

    public var name: String {
        switch self {
        case .c: return "C"
        case .cSharp: return "C♯"
        case .d: return "D"
        case .dSharp: return "D♯"
        case .e: return "E"
        case .f: return "F"
        case .fSharp: return "F♯"
        case .g: return "G"
        case .gSharp: return "G♯"
        case .a: return "A"
        case .aSharp: return "A♯"
        case .b: return "B"
        }
    }

    public var flatName: String {
        switch self {
        case .cSharp: return "D♭"
        case .dSharp: return "E♭"
        case .fSharp: return "G♭"
        case .gSharp: return "A♭"
        case .aSharp: return "B♭"
        default: return name
        }
    }
}

/// Scale mode (Major / Minor).
public enum ScaleMode: String, CaseIterable, Codable, Sendable {
    case major = "Maj"
    case minor = "Min"

    public var fullName: String {
        switch self {
        case .major: return "Major"
        case .minor: return "Minor"
        }
    }

    /// Relative minor offset (A minor is C major - 3 semitones down)
    public var relativeOffset: Int {
        switch self {
        case .major: return 0
        case .minor: return 3
        }
    }
}

/// Represents a complete musical key (e.g. "C Major", "F# Minor")
public struct MusicalKey: Equatable, Hashable, Codable, Sendable {
    public var pitch: PitchClass
    public var mode: ScaleMode

    public init(pitch: PitchClass = .c, mode: ScaleMode = .major) {
        self.pitch = pitch
        self.mode = mode
    }

    public var displayName: String {
        "\(pitch.name) \(mode.rawValue)"
    }

    public var fullDisplayName: String {
        "\(pitch.name) \(mode.fullName)"
    }

    /// Calculates semitone shift needed to harmonize a source key with this master key.
    /// Returns interval in semitones in range [-6, 6] to minimize pitch warping.
    public func semitones(from source: MusicalKey) -> Int {
        let sourcePitchVal = source.pitch.rawValue
        let targetPitchVal = self.pitch.rawValue

        // Account for mode transition if different (simple modal shift approximation: minor to major is +3 semitones)
        let modeDelta: Int
        if source.mode != self.mode {
            modeDelta = (self.mode == .major) ? 3 : -3
        } else {
            modeDelta = 0
        }

        var delta = (targetPitchVal - sourcePitchVal + modeDelta) % 12
        if delta > 6 {
            delta -= 12
        } else if delta < -6 {
            delta += 12
        }
        return delta
    }

    /// Converts semitone shift to pitch cents for AVAudioUnitTimePitch (-2400 to +2400 cents)
    public func pitchShiftCents(from source: MusicalKey) -> Float {
        Float(semitones(from: source)) * 100.0
    }

    public static let standardKeys: [MusicalKey] = {
        var list: [MusicalKey] = []
        for p in PitchClass.allCases {
            list.append(MusicalKey(pitch: p, mode: .major))
            list.append(MusicalKey(pitch: p, mode: .minor))
        }
        return list
    }()
}
