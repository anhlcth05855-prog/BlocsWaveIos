import Foundation

/// Central registry of all 40+ procedural sound presets across 5 genres and 8 track types.
public final class SoundLibrary {

    public static let allPresets: [SoundPreset] = [
        // MARK: - Synthwave 80s
        SoundPreset(id: "sw_kick", name: "80s Analog Kick", genre: .synthwave, trackType: .kick, description: "Punchy electro kick with 48Hz sub transient"),
        SoundPreset(id: "sw_snare", name: "Gated Reverb Snare", genre: .synthwave, trackType: .snare, description: "Crisp 80s snare with gated white noise tail"),
        SoundPreset(id: "sw_hihat", name: "Neon 16th Hi-Hats", genre: .synthwave, trackType: .hihat, description: "Closed hats with offbeat accent swing"),
        SoundPreset(id: "sw_bass", name: "Rolling Cyber Bass", genre: .synthwave, trackType: .bass, description: "Sawtooth & sub bassline in C minor"),
        SoundPreset(id: "sw_chords", name: "Juno Detuned Chords", genre: .synthwave, trackType: .chords, description: "Lush 7th & 9th analog synth pads"),
        SoundPreset(id: "sw_lead", name: "Laser Synth Arp", genre: .synthwave, trackType: .lead, description: "16th-note square arpeggiator hook"),
        SoundPreset(id: "sw_pluck", name: "Glass Upbeat Pluck", genre: .synthwave, trackType: .pluck, description: "Melodic syncopated FM glass pluck"),
        SoundPreset(id: "sw_vocalfx", name: "Formant Tape Riser", genre: .synthwave, trackType: .vocalFX, description: "Vocal formant filter sweep & riser"),

        // MARK: - EDM Club House
        SoundPreset(id: "edm_kick", name: "Festival Club Kick", genre: .edm, trackType: .kick, description: "4-on-the-floor deep punchy electro kick"),
        SoundPreset(id: "edm_snare", name: "Stadium Clap & Snare", genre: .edm, trackType: .snare, description: "Wide stereo layered handclaps on 2 & 4"),
        SoundPreset(id: "edm_hihat", name: "909 Open Hats & Shaker", genre: .edm, trackType: .hihat, description: "Energetic offbeat open hat groove"),
        SoundPreset(id: "edm_bass", name: "Bounce Donk Bass", genre: .edm, trackType: .bass, description: "Punchy offbeat Melbourne bounce bass"),
        SoundPreset(id: "edm_chords", name: "Rave Piano Stabs", genre: .edm, trackType: .chords, description: "90s classic house piano chord progression"),
        SoundPreset(id: "edm_lead", name: "Festival Anthemic Lead", genre: .edm, trackType: .lead, description: "Unison supersaw soaring anthemic melody"),
        SoundPreset(id: "edm_pluck", name: "Eurodance Pluck", genre: .edm, trackType: .pluck, description: "Bouncy syncopated pluck counterpoint"),
        SoundPreset(id: "edm_vocalfx", name: "Future Vocal Chops", genre: .edm, trackType: .vocalFX, description: "Rhythmic pitched vocal hook pattern"),

        // MARK: - 808 Trap & Hip-Hop
        SoundPreset(id: "trap_kick", name: "Heavy 808 Sub Kick", genre: .trap, trackType: .kick, description: "Sub bass boom with pitch sweep and saturation"),
        SoundPreset(id: "trap_snare", name: "Digital Trap Snare", genre: .trap, trackType: .snare, description: "Tight rimshot snare with 32nd roll on bar 2"),
        SoundPreset(id: "trap_hihat", name: "Triplet Hi-Hat Rolls", genre: .trap, trackType: .hihat, description: "Fast trap hats with pitch glide triplet rolls"),
        SoundPreset(id: "trap_bass", name: "Distorted 808 Slide", genre: .trap, trackType: .bass, description: "Low 38Hz glide bassline with soft clipping"),
        SoundPreset(id: "trap_chords", name: "Dark Minor Bells", genre: .trap, trackType: .chords, description: "Eerie music box minor chord progression"),
        SoundPreset(id: "trap_lead", name: "Trap Whistle / Flute", genre: .trap, trackType: .lead, description: "Melodic pitch-bent synth flute lead"),
        SoundPreset(id: "trap_pluck", name: "Pizzicato Pluck", genre: .trap, trackType: .pluck, description: "Staccato orchestral string bounce"),
        SoundPreset(id: "trap_vocalfx", name: "Trap Vox Chant & Scratch", genre: .trap, trackType: .vocalFX, description: "Chant 'Hey!' hit and vinyl rewind"),

        // MARK: - Lo-Fi Chillout
        SoundPreset(id: "lofi_kick", name: "Dusty Vinyl Kick", genre: .lofi, trackType: .kick, description: "Low-passed boom bap kick with tape warmth"),
        SoundPreset(id: "lofi_snare", name: "Finger Snap & Rimshot", genre: .lofi, trackType: .snare, description: "Warm acoustic rim-click with subtle vinyl dust"),
        SoundPreset(id: "lofi_hihat", name: "Swung Shaker & Hats", genre: .lofi, trackType: .hihat, description: "Relaxed humanized swing groove"),
        SoundPreset(id: "lofi_bass", name: "Upright Jazz Bass", genre: .lofi, trackType: .bass, description: "Deep warm acoustic double bass round tone"),
        SoundPreset(id: "lofi_chords", name: "Rhodes Electric Piano", genre: .lofi, trackType: .chords, description: "Lush jazz chords with gentle tremolo"),
        SoundPreset(id: "lofi_lead", name: "Vibraphone Chime", genre: .lofi, trackType: .lead, description: "Nostalgic music box & mallet melody"),
        SoundPreset(id: "lofi_pluck", name: "Muted Nylon Guitar", genre: .lofi, trackType: .pluck, description: "Acoustic jazz guitar chord plucks"),
        SoundPreset(id: "lofi_vocalfx", name: "Radio Vocal & Rain Ambiance", genre: .lofi, trackType: .vocalFX, description: "Bandpass filtered nostalgic voice sample"),

        // MARK: - Acoustic & Funk
        SoundPreset(id: "ac_kick", name: "Wood Cajon Stomp", genre: .acoustic, trackType: .kick, description: "Acoustic cajon box kick with resonant body"),
        SoundPreset(id: "ac_snare", name: "Rim-Click & Claps", genre: .acoustic, trackType: .snare, description: "Organic acoustic snare click & handclaps"),
        SoundPreset(id: "ac_hihat", name: "Tambourine & Shaker", genre: .acoustic, trackType: .hihat, description: "Crisp brass jingle tambourine 16th groove"),
        SoundPreset(id: "ac_bass", name: "Funky Slap Bass", genre: .acoustic, trackType: .bass, description: "Thumb slaps and popped funk bassline"),
        SoundPreset(id: "ac_chords", name: "Wah Rhythm Guitar", genre: .acoustic, trackType: .chords, description: "16th-note funk rhythm guitar chops"),
        SoundPreset(id: "ac_lead", name: "Brass Horn Stabs", genre: .acoustic, trackType: .lead, description: "Energetic trumpet and sax section stabs"),
        SoundPreset(id: "ac_pluck", name: "African Kalimba Pluck", genre: .acoustic, trackType: .pluck, description: "Melodic thumb piano counterpoint"),
        SoundPreset(id: "ac_vocalfx", name: "Soulful Vocal Groove", genre: .acoustic, trackType: .vocalFX, description: "Live crowd vocal chops and shaker fill")
    ]

    /// Returns presets filtered by track type
    public static func presets(for type: TrackType) -> [SoundPreset] {
        allPresets.filter { $0.trackType == type }
    }

    /// Returns presets for a given genre pack
    public static func presets(for genre: SoundGenre) -> [SoundPreset] {
        allPresets.filter { $0.genre == genre }
    }

    /// Returns preset for a given track type and genre
    public static func preset(type: TrackType, genre: SoundGenre) -> SoundPreset? {
        allPresets.first { $0.trackType == type && $0.genre == genre }
    }
}
