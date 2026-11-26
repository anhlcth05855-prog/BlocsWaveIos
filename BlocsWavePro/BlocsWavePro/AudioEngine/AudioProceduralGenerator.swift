import Foundation
import AVFoundation

/// Synthesizes 40+ high-fidelity electronic & acoustic music loops directly into PCM buffers.
/// Supports 5 sound packs: Synthwave 80s, EDM Club House, 808 Trap, Lo-Fi Chillout, and Acoustic Funk.
public final class AudioProceduralGenerator {

    public static let defaultBPM: Double = 124.0
    public static let sampleRate: Double = 44100.0

    /// Generates a complete 2-bar (8-beat) audio buffer for a given track type and sound genre.
    public static func generateTrackLoop(
        for type: TrackType,
        genre: SoundGenre = .synthwave,
        bpm: Double = defaultBPM,
        bars: Int = 2
    ) -> AVAudioPCMBuffer {
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2)!
        let totalBeats = Double(bars * 4)
        let totalSeconds = (60.0 / bpm) * totalBeats
        let frameCount = AVAudioFrameCount(totalSeconds * sampleRate)

        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buffer.frameLength = frameCount

        guard let left = buffer.floatChannelData?[0],
              let right = buffer.floatChannelData?[1] else {
            return buffer
        }

        let secondsPerBeat = 60.0 / bpm
        let framesCountInt = Int(frameCount)

        for i in 0..<framesCountInt {
            let t = Double(i) / sampleRate
            let currentBeat = t / secondsPerBeat

            var (sampleL, sampleR): (Float, Float) = (0.0, 0.0)

            switch genre {
            case .synthwave:
                (sampleL, sampleR) = synthesizeSynthwave(type: type, beat: currentBeat, t: t, secondsPerBeat: secondsPerBeat, totalSeconds: totalSeconds)
            case .edm:
                (sampleL, sampleR) = synthesizeEDM(type: type, beat: currentBeat, t: t, secondsPerBeat: secondsPerBeat, totalSeconds: totalSeconds)
            case .trap:
                (sampleL, sampleR) = synthesizeTrap(type: type, beat: currentBeat, t: t, secondsPerBeat: secondsPerBeat, totalSeconds: totalSeconds)
            case .lofi:
                (sampleL, sampleR) = synthesizeLoFi(type: type, beat: currentBeat, t: t, secondsPerBeat: secondsPerBeat, totalSeconds: totalSeconds)
            case .acoustic:
                (sampleL, sampleR) = synthesizeAcoustic(type: type, beat: currentBeat, t: t, secondsPerBeat: secondsPerBeat, totalSeconds: totalSeconds)
            }

            // Loop boundary de-clicking (2ms crossfade at start and end)
            let fadeFrames = Int(0.002 * sampleRate)
            var window: Float = 1.0
            if i < fadeFrames {
                window = Float(i) / Float(fadeFrames)
            } else if i > framesCountInt - fadeFrames {
                window = Float(framesCountInt - i) / Float(fadeFrames)
            }

            left[i] = sampleL * window
            right[i] = sampleR * window
        }

        return buffer
    }

    // MARK: - 1. Synthwave 80s Synthesizer
    private static func synthesizeSynthwave(type: TrackType, beat: Double, t: Double, secondsPerBeat: Double, totalSeconds: Double) -> (Float, Float) {
        switch type {
        case .kick:
            let beatPhase = beat.truncatingRemainder(dividingBy: 1.0)
            let timeInBeat = beatPhase * secondsPerBeat
            if timeInBeat < 0.3 {
                let pitch = 48.0 + 110.0 * exp(-timeInBeat * 32.0)
                let env = Float(exp(-timeInBeat * 12.0))
                let click = (timeInBeat < 0.006) ? Float.random(in: -0.25...0.25) : 0.0
                let v = (Float(sin(2.0 * .pi * pitch * timeInBeat)) + click) * env * 0.95
                return (v, v)
            }
            return (0, 0)

        case .snare:
            let beatIdx = Int(beat) % 8
            if beatIdx % 2 == 1 {
                let timeInBeat = beat.truncatingRemainder(dividingBy: 1.0) * secondsPerBeat
                if timeInBeat < 0.28 {
                    let tone = sin(2.0 * .pi * 190.0 * timeInBeat) * exp(-timeInBeat * 22.0)
                    let noiseL = Double.random(in: -1.0...1.0) * exp(-timeInBeat * 14.0)
                    let noiseR = Double.random(in: -1.0...1.0) * exp(-timeInBeat * 14.0)
                    return (Float(tone * 0.4 + noiseL * 0.6) * 0.85, Float(tone * 0.4 + noiseR * 0.6) * 0.85)
                }
            }
            return (0, 0)

        case .hihat:
            let sixteenth = (beat * 4.0).truncatingRemainder(dividingBy: 1.0)
            let time16 = sixteenth * (secondsPerBeat / 4.0)
            if time16 < 0.065 {
                let step = Int(beat * 4.0) % 16
                let isAccent = (step % 2 == 1)
                let env = Float(exp(-time16 * (isAccent ? 75.0 : 120.0))) * (isAccent ? 0.7 : 0.35)
                let noise = Float.random(in: -1.0...1.0) * env
                return (noise, noise)
            }
            return (0, 0)

        case .bass:
            let notes: [(b: Double, d: Double, f: Double)] = [
                (0.0, 0.75, 65.4), (1.0, 0.5, 65.4), (1.75, 0.25, 77.78),
                (2.0, 0.75, 87.3), (3.0, 0.75, 98.0), (4.0, 0.75, 65.4),
                (5.0, 0.5, 65.4), (5.5, 0.5, 58.27), (6.0, 0.75, 77.78), (7.0, 0.75, 65.4)
            ]
            let b8 = beat.truncatingRemainder(dividingBy: 8.0)
            for n in notes {
                if b8 >= n.b && b8 < (n.b + n.d) {
                    let nt = (b8 - n.b) * secondsPerBeat
                    let env = Float(exp(-nt * 4.2))
                    let saw = Float((t * n.f).truncatingRemainder(dividingBy: 1.0) * 2.0 - 1.0)
                    let sub = Float(sin(2.0 * .pi * (n.f * 0.5) * t))
                    let v = (saw * 0.45 + sub * 0.55) * env * 0.85
                    return (v, v)
                }
            }
            return (0, 0)

        case .chords:
            let bar = Int(beat / 2.0) % 4
            let freqs: [Double]
            switch bar {
            case 0: freqs = [130.81, 155.56, 196.00, 233.08] // Cm7
            case 1: freqs = [103.83, 130.81, 155.56, 196.00] // Abmaj7
            case 2: freqs = [174.61, 207.65, 261.63, 311.13] // Fm7
            default: freqs = [196.00, 233.08, 293.66, 349.23] // Gm7
            }
            let ct = beat.truncatingRemainder(dividingBy: 2.0) * secondsPerBeat
            let env = Float(exp(-ct * 1.8) * (1.0 - exp(-ct * 40.0)))
            var vl: Double = 0, vr: Double = 0
            for (idx, f) in freqs.enumerated() {
                let detune = Double(idx) * 0.75 - 1.1
                vl += sin(2.0 * .pi * (f - detune) * t)
                vr += sin(2.0 * .pi * (f + detune) * t)
            }
            return (Float(vl * 0.16) * env, Float(vr * 0.16) * env)

        case .lead:
            let arp = [261.63, 311.13, 392.00, 466.16, 523.25, 466.16, 392.00, 311.13]
            let f = arp[Int(beat * 4.0) % 8]
            let time16 = (beat * 4.0).truncatingRemainder(dividingBy: 1.0) * (secondsPerBeat / 4.0)
            let env = Float(exp(-time16 * 18.0))
            let sqr: Float = sin(2.0 * .pi * f * t) > 0 ? 0.6 : -0.6
            let v = sqr * env * 0.38
            return (v * 0.8, v * 1.2)

        case .pluck:
            let step = Int(beat * 2.0) % 8
            if step == 1 || step == 3 || step == 6 {
                let pt = (beat * 2.0).truncatingRemainder(dividingBy: 1.0) * (secondsPerBeat / 2.0)
                let env = Float(exp(-pt * 12.0))
                let v = Float(sin(2.0 * .pi * 523.25 * t)) * env * 0.45
                return (v * 0.7, v * 0.9)
            }
            return (0, 0)

        case .vocalFX:
            let ct = beat.truncatingRemainder(dividingBy: 1.0) * secondsPerBeat
            let f = 400.0 + (t / totalSeconds) * 800.0
            let env = ct < 0.22 ? Float(exp(-ct * 12.0)) : 0.0
            let v = Float(sin(2.0 * .pi * f * t) * sin(2.0 * .pi * 800.0 * t)) * env * 0.35
            return (v, v)
        }
    }

    // MARK: - 2. EDM Club House Synthesizer
    private static func synthesizeEDM(type: TrackType, beat: Double, t: Double, secondsPerBeat: Double, totalSeconds: Double) -> (Float, Float) {
        switch type {
        case .kick: // Punchy electro 4-to-the-floor
            let bt = beat.truncatingRemainder(dividingBy: 1.0) * secondsPerBeat
            if bt < 0.28 {
                let pitch = 52.0 + 130.0 * exp(-bt * 38.0)
                let env = Float(exp(-bt * 14.0))
                let click = (bt < 0.005) ? Float.random(in: -0.4...0.4) : 0.0
                let v = (Float(sin(2.0 * .pi * pitch * bt)) + click) * env
                return (v, v)
            }
            return (0, 0)

        case .snare: // Wide Stadium Clap on 2 & 4
            let beatIdx = Int(beat) % 8
            if beatIdx % 2 == 1 {
                let bt = beat.truncatingRemainder(dividingBy: 1.0) * secondsPerBeat
                if bt < 0.22 {
                    let flam = (bt < 0.015) ? 0.6 : 1.0
                    let noiseL = Float.random(in: -1.0...1.0) * Float(exp(-bt * 18.0) * flam)
                    let noiseR = Float.random(in: -1.0...1.0) * Float(exp(-bt * 18.0) * flam)
                    return (noiseL * 0.85, noiseR * 0.85)
                }
            }
            return (0, 0)

        case .hihat: // 909 Open Hats on Offbeat
            let offbeat = (beat + 0.5).truncatingRemainder(dividingBy: 1.0)
            let ht = offbeat * secondsPerBeat
            if ht < 0.18 {
                let env = Float(exp(-ht * 24.0))
                let noise = Float.random(in: -1.0...1.0) * env * 0.7
                return (noise, noise)
            }
            return (0, 0)

        case .bass: // Bouncy Melbourne / Donk Bass
            let offbeat = (beat + 0.5).truncatingRemainder(dividingBy: 1.0)
            let bt = offbeat * secondsPerBeat
            if bt < 0.22 {
                let barIdx = Int(beat) % 8
                let freqs = [65.4, 65.4, 77.78, 87.3, 65.4, 65.4, 98.0, 77.78]
                let f = freqs[barIdx]
                let pitchMod = f * (1.0 + 2.0 * exp(-bt * 40.0))
                let env = Float(exp(-bt * 8.0))
                let v = Float(sin(2.0 * .pi * pitchMod * bt)) * env * 0.9
                return (v, v)
            }
            return (0, 0)

        case .chords: // Rave House Piano Stabs
            let beatInBar = beat.truncatingRemainder(dividingBy: 1.0)
            if beatInBar < 0.3 || (beatInBar > 0.5 && beatInBar < 0.8) {
                let pt = (beatInBar < 0.5 ? beatInBar : beatInBar - 0.5) * secondsPerBeat
                let env = Float(exp(-pt * 8.0))
                let chord = [261.63, 329.63, 392.00, 493.88]
                var v: Float = 0
                for f in chord { v += Float(sin(2.0 * .pi * f * t)) }
                return (v * 0.15 * env, v * 0.15 * env)
            }
            return (0, 0)

        case .lead: // Festival Anthem Supersaw
            let notes = [523.25, 587.33, 659.25, 783.99, 659.25, 587.33, 523.25, 392.0]
            let f = notes[Int(beat) % 8]
            let bt = beat.truncatingRemainder(dividingBy: 1.0) * secondsPerBeat
            let env = Float(exp(-bt * 3.5))
            var vl: Float = 0, vr: Float = 0
            for s in -2...2 {
                vl += Float((t * (f + Double(s) * 1.5)).truncatingRemainder(dividingBy: 1.0) * 2.0 - 1.0) * 0.12
                vr += Float((t * (f - Double(s) * 1.5)).truncatingRemainder(dividingBy: 1.0) * 2.0 - 1.0) * 0.12
            }
            return (vl * env, vr * env)

        case .pluck: // Eurodance Pluck
            let step = Int(beat * 4.0) % 16
            if step % 3 == 0 {
                let pt = (beat * 4.0).truncatingRemainder(dividingBy: 1.0) * (secondsPerBeat / 4.0)
                let env = Float(exp(-pt * 18.0))
                let v = Float(sin(2.0 * .pi * 659.25 * t)) * env * 0.45
                return (v * 0.6, v * 0.9)
            }
            return (0, 0)

        case .vocalFX: // Future Vocal Chops
            let step = Int(beat * 2.0) % 8
            let fList = [600.0, 750.0, 900.0, 600.0, 800.0, 950.0, 700.0, 850.0]
            let f = fList[step]
            let vt = (beat * 2.0).truncatingRemainder(dividingBy: 1.0) * (secondsPerBeat / 2.0)
            if vt < 0.2 {
                let env = Float(exp(-vt * 14.0))
                let v = Float(sin(2.0 * .pi * f * t) * sin(2.0 * .pi * 220.0 * t)) * env * 0.4
                return (v, v)
            }
            return (0, 0)
        }
    }

    // MARK: - 3. 808 Trap & Hip-Hop Synthesizer
    private static func synthesizeTrap(type: TrackType, beat: Double, t: Double, secondsPerBeat: Double, totalSeconds: Double) -> (Float, Float) {
        switch type {
        case .kick: // Saturated 808 Sub Kick
            let beatIdx = Int(beat) % 8
            if beatIdx == 0 || beatIdx == 3 || beatIdx == 5 {
                let bt = beat.truncatingRemainder(dividingBy: 1.0) * secondsPerBeat
                if bt < 0.55 {
                    let pitch = 38.0 + 90.0 * exp(-bt * 45.0)
                    let env = Float(exp(-bt * 6.5))
                    var v = Float(sin(2.0 * .pi * pitch * bt)) * env
                    v = tanh(v * 1.5)
                    return (v * 0.9, v * 0.9)
                }
            }
            return (0, 0)

        case .snare: // Trap Rim & 32nd roll on bar 2
            let beatIn8 = beat.truncatingRemainder(dividingBy: 8.0)
            if Int(beatIn8) == 2 || Int(beatIn8) == 6 {
                let bt = beat.truncatingRemainder(dividingBy: 1.0) * secondsPerBeat
                if bt < 0.18 {
                    let v = Float.random(in: -1.0...1.0) * Float(exp(-bt * 28.0)) * 0.85
                    return (v, v)
                }
            } else if beatIn8 >= 7.5 { // Rapid 32nd roll
                let rollStep = (beatIn8 * 8.0).truncatingRemainder(dividingBy: 1.0) * (secondsPerBeat / 8.0)
                if rollStep < 0.05 {
                    let v = Float.random(in: -1.0...1.0) * Float(exp(-rollStep * 40.0)) * 0.7
                    return (v, v)
                }
            }
            return (0, 0)

        case .hihat: // Fast Trap Hi-Hats with Triplet Rolls
            let step = Int(beat * 4.0) % 16
            let isRoll = (step == 10 || step == 11 || step == 14)
            let subDiv = isRoll ? 6.0 : 4.0
            let ht = (beat * subDiv).truncatingRemainder(dividingBy: 1.0) * (secondsPerBeat / subDiv)
            if ht < 0.045 {
                let env = Float(exp(-ht * 90.0)) * 0.6
                let v = Float.random(in: -1.0...1.0) * env
                return (v, v)
            }
            return (0, 0)

        case .bass: // 808 Glide Bass
            let b8 = beat.truncatingRemainder(dividingBy: 8.0)
            let notes: [(b: Double, d: Double, f: Double)] = [(0, 2, 32.7), (2.5, 1.5, 38.9), (4, 2, 43.6), (6, 2, 49.0)]
            for n in notes {
                if b8 >= n.b && b8 < (n.b + n.d) {
                    let nt = (b8 - n.b) * secondsPerBeat
                    let env = Float(exp(-nt * 2.0))
                    let v = tanh(Float(sin(2.0 * .pi * n.f * t)) * 2.2) * env * 0.8
                    return (v, v)
                }
            }
            return (0, 0)

        case .chords: // Dark Minor Bell Chords
            let chordIdx = Int(beat / 2.0) % 4
            let freqs = [[261.63, 311.13, 392.00], [246.94, 293.66, 369.99], [220.00, 261.63, 329.63], [246.94, 311.13, 369.99]][chordIdx]
            let ct = beat.truncatingRemainder(dividingBy: 2.0) * secondsPerBeat
            let env = Float(exp(-ct * 2.5))
            var v: Float = 0
            for f in freqs { v += Float(sin(2.0 * .pi * f * t) + 0.3 * sin(2.0 * .pi * f * 2.0 * t)) }
            return (v * 0.16 * env, v * 0.16 * env)

        case .lead: // Trap Whistle / Flute
            let notes = [587.33, 659.25, 783.99, 880.00]
            let f = notes[Int(beat * 2.0) % 4]
            let ft = (beat * 2.0).truncatingRemainder(dividingBy: 1.0) * (secondsPerBeat / 2.0)
            let env = Float(exp(-ft * 5.0) * (1.0 - exp(-ft * 30.0)))
            let v = Float(sin(2.0 * .pi * f * t)) * env * 0.38
            return (v * 0.7, v * 1.1)

        case .pluck: // Pizzicato String Pluck
            let pt = (beat * 2.0).truncatingRemainder(dividingBy: 1.0) * (secondsPerBeat / 2.0)
            if pt < 0.12 {
                let env = Float(exp(-pt * 25.0))
                let v = Float(sin(2.0 * .pi * 440.0 * t) + sin(2.0 * .pi * 880.0 * t) * 0.5) * env * 0.5
                return (v, v * 0.8)
            }
            return (0, 0)

        case .vocalFX: // Chant "Hey!" & Scratch
            let step = Int(beat) % 8
            if step == 2 || step == 6 {
                let ct = beat.truncatingRemainder(dividingBy: 1.0) * secondsPerBeat
                if ct < 0.25 {
                    let env = Float(exp(-ct * 12.0))
                    let v = Float(sin(2.0 * .pi * 520.0 * ct) * sin(2.0 * .pi * 180.0 * ct)) * env * 0.6
                    return (v, v)
                }
            }
            return (0, 0)
        }
    }

    // MARK: - 4. Lo-Fi Chillout Synthesizer
    private static func synthesizeLoFi(type: TrackType, beat: Double, t: Double, secondsPerBeat: Double, totalSeconds: Double) -> (Float, Float) {
        let vinylNoise = (Float.random(in: 0...1) < 0.03) ? Float.random(in: -0.04...0.04) : 0.0

        switch type {
        case .kick: // Warm Boom-Bap Kick
            let beatIn8 = beat.truncatingRemainder(dividingBy: 8.0)
            let isKick = (beatIn8 < 0.5 || (beatIn8 >= 2.75 && beatIn8 < 3.25) || (beatIn8 >= 4.0 && beatIn8 < 4.5))
            if isKick {
                let bt = beat.truncatingRemainder(dividingBy: 1.0) * secondsPerBeat
                if bt < 0.35 {
                    let pitch = 44.0 + 85.0 * exp(-bt * 24.0)
                    let env = Float(exp(-bt * 8.5))
                    let v = Float(sin(2.0 * .pi * pitch * bt)) * env * 0.85
                    return (v + vinylNoise, v + vinylNoise)
                }
            }
            return (vinylNoise, vinylNoise)

        case .snare: // Soft Rimshot & Finger Snap
            let beatIdx = Int(beat) % 8
            if beatIdx % 2 == 1 {
                let bt = beat.truncatingRemainder(dividingBy: 1.0) * secondsPerBeat
                if bt < 0.16 {
                    let snap = Float(sin(2.0 * .pi * 850.0 * bt) * exp(-bt * 35.0)) * 0.4
                    let wood = Float.random(in: -1.0...1.0) * Float(exp(-bt * 25.0)) * 0.35
                    let v = (snap + wood) * 0.75
                    return (v, v)
                }
            }
            return (0, 0)

        case .hihat: // Swung Shaker Groove
            let time16 = (beat * 4.0 + 0.15).truncatingRemainder(dividingBy: 1.0) * (secondsPerBeat / 4.0)
            if time16 < 0.08 {
                let env = Float(exp(-time16 * 45.0)) * 0.28
                let noise = Float.random(in: -1.0...1.0) * env
                return (noise, noise)
            }
            return (0, 0)

        case .bass: // Upright Acoustic Jazz Bass
            let notes = [65.4, 77.78, 58.27, 49.0]
            let f = notes[Int(beat / 2.0) % 4]
            let bt = beat.truncatingRemainder(dividingBy: 2.0) * secondsPerBeat
            let env = Float(exp(-bt * 2.2))
            let v = Float(sin(2.0 * .pi * f * t)) * env * 0.75
            return (v, v)

        case .chords: // Rhodes Electric Piano
            let bar = Int(beat / 2.0) % 4
            let chords = [[130.81, 196.00, 261.63, 311.13], [116.54, 174.61, 233.08, 293.66], [103.83, 155.56, 207.65, 261.63], [98.00, 146.83, 196.00, 246.94]][bar]
            let ct = beat.truncatingRemainder(dividingBy: 2.0) * secondsPerBeat
            let env = Float(exp(-ct * 1.4))
            let wow = sin(2.0 * .pi * 4.5 * t) * 0.8
            var v: Float = 0
            for f in chords { v += Float(sin(2.0 * .pi * (f + wow) * t)) }
            return (v * 0.12 * env, v * 0.12 * env)

        case .lead: // Vibraphone Melody
            let notes = [523.25, 587.33, 659.25, 783.99]
            let f = notes[Int(beat) % 4]
            let vt = beat.truncatingRemainder(dividingBy: 1.0) * secondsPerBeat
            let env = Float(exp(-vt * 3.8))
            let v = Float(sin(2.0 * .pi * f * t)) * env * 0.32
            return (v * 0.8, v * 1.1)

        case .pluck: // Muted Nylon Guitar
            let step = Int(beat * 2.0) % 8
            if step == 2 || step == 5 {
                let gt = (beat * 2.0).truncatingRemainder(dividingBy: 1.0) * (secondsPerBeat / 2.0)
                let env = Float(exp(-gt * 10.0))
                let v = Float(sin(2.0 * .pi * 330.0 * t) + sin(2.0 * .pi * 660.0 * t) * 0.4) * env * 0.45
                return (v, v * 0.9)
            }
            return (0, 0)

        case .vocalFX: // Radio Vocal & Rain Ambiance
            let vt = beat.truncatingRemainder(dividingBy: 2.0) * secondsPerBeat
            if vt < 0.4 {
                let env = Float(exp(-vt * 6.0))
                let v = Float(sin(2.0 * .pi * 680.0 * t)) * env * 0.25
                return (v + vinylNoise, v + vinylNoise)
            }
            return (vinylNoise, vinylNoise)
        }
    }

    // MARK: - 5. Acoustic & Funk Synthesizer
    private static func synthesizeAcoustic(type: TrackType, beat: Double, t: Double, secondsPerBeat: Double, totalSeconds: Double) -> (Float, Float) {
        switch type {
        case .kick: // Cajon Stomp Kick
            let beatIn8 = beat.truncatingRemainder(dividingBy: 8.0)
            let isKick = (beatIn8 < 0.5 || (beatIn8 >= 2.5 && beatIn8 < 3.0) || (beatIn8 >= 4.0 && beatIn8 < 4.5))
            if isKick {
                let bt = beat.truncatingRemainder(dividingBy: 1.0) * secondsPerBeat
                if bt < 0.25 {
                    let pitch = 65.0 + 80.0 * exp(-bt * 35.0)
                    let env = Float(exp(-bt * 14.0))
                    let slap = (bt < 0.008) ? Float.random(in: 0...0.3) : 0.0
                    let v = (Float(sin(2.0 * .pi * pitch * bt)) + slap) * env * 0.85
                    return (v, v)
                }
            }
            return (0, 0)

        case .snare: // Rimshot & Handclap
            let beatIdx = Int(beat) % 8
            if beatIdx % 2 == 1 {
                let bt = beat.truncatingRemainder(dividingBy: 1.0) * secondsPerBeat
                if bt < 0.2 {
                    let tone = sin(2.0 * .pi * 320.0 * bt) * exp(-bt * 30.0)
                    let noise = Double.random(in: -1.0...1.0) * exp(-bt * 18.0)
                    let v = Float(tone * 0.5 + noise * 0.5) * 0.8
                    return (v, v)
                }
            }
            return (0, 0)

        case .hihat: // Tambourine & Shaker
            let step = Int(beat * 4.0) % 16
            let tt = (beat * 4.0).truncatingRemainder(dividingBy: 1.0) * (secondsPerBeat / 4.0)
            if tt < 0.08 {
                let jingle = Float(sin(2.0 * .pi * 4500.0 * tt)) * 0.3
                let noise = Float.random(in: -1.0...1.0) * 0.7
                let env = Float(exp(-tt * 40.0))
                let v = (jingle + noise) * env * (step % 4 == 2 ? 0.65 : 0.35)
                return (v, v)
            }
            return (0, 0)

        case .bass: // Funky Slap Bass
            let b8 = beat.truncatingRemainder(dividingBy: 8.0)
            let notes: [(b: Double, d: Double, f: Double)] = [(0, 0.5, 82.4), (0.75, 0.25, 98.0), (1.5, 0.5, 110.0), (2, 0.5, 82.4), (3.5, 0.5, 73.4), (4, 0.5, 82.4), (5.5, 0.5, 98.0)]
            for n in notes {
                if b8 >= n.b && b8 < (n.b + n.d) {
                    let nt = (b8 - n.b) * secondsPerBeat
                    let env = Float(exp(-nt * 8.0))
                    let pop: Float = (nt < 0.01) ? 1.5 : 1.0
                    let v = Float(sin(2.0 * .pi * n.f * t)) * env * pop * 0.85
                    return (v, v)
                }
            }
            return (0, 0)

        case .chords: // Wah Funk Rhythm Guitar
            let step = Int(beat * 4.0) % 16
            if step % 2 == 1 {
                let gt = (beat * 4.0).truncatingRemainder(dividingBy: 1.0) * (secondsPerBeat / 4.0)
                let wah = 600.0 + 1200.0 * sin(2.0 * .pi * 2.0 * t)
                let env = Float(exp(-gt * 15.0))
                let v = Float(sin(2.0 * .pi * wah * t) * 0.5 + sin(2.0 * .pi * 330.0 * t) * 0.5) * env * 0.4
                return (v * 0.8, v * 1.1)
            }
            return (0, 0)

        case .lead: // Brass Horn Stabs
            let beatIn8 = beat.truncatingRemainder(dividingBy: 8.0)
            let stabBeats = [0.0, 2.5, 4.0, 6.5]
            for stab in stabBeats {
                let deltaBeats = beatIn8 - stab
                if deltaBeats >= 0 {
                    let bt = deltaBeats * secondsPerBeat
                    if bt < 0.28 {
                        let env = Float(exp(-bt * 6.0))
                        let chord = [349.23, 440.00, 523.25]
                        var v: Float = 0
                        for f in chord { v += Float(sin(2.0 * .pi * f * t) * 0.35 + sin(2.0 * .pi * f * 2.0 * t) * 0.15) }
                        return (v * env, v * env)
                    }
                }
            }
            return (0, 0)

        case .pluck: // Kalimba Thumb Piano
            let kalimba = [523.25, 659.25, 783.99, 880.00, 1046.5]
            let f = kalimba[Int(beat * 2.0) % kalimba.count]
            let kt = (beat * 2.0).truncatingRemainder(dividingBy: 1.0) * (secondsPerBeat / 2.0)
            let env = Float(exp(-kt * 10.0))
            let v = Float(sin(2.0 * .pi * f * t)) * env * 0.38
            return (v * 1.1, v * 0.8)

        case .vocalFX: // Funk Vocal Groove
            let beatIdx = Int(beat) % 8
            if beatIdx == 3 || beatIdx == 7 {
                let vt = beat.truncatingRemainder(dividingBy: 1.0) * secondsPerBeat
                if vt < 0.22 {
                    let env = Float(exp(-vt * 12.0))
                    let v = Float(sin(2.0 * .pi * 450.0 * t) * sin(2.0 * .pi * 180.0 * t)) * env * 0.45
                    return (v, v)
                }
            }
            return (0, 0)
        }
    }
}
