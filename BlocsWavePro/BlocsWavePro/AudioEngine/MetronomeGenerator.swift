import Foundation
import AVFoundation

/// Generates accurate synthetic metronome clicks for downbeats and regular beats.
public final class MetronomeGenerator {
    public let downbeatBuffer: AVAudioPCMBuffer
    public let regularBeatBuffer: AVAudioPCMBuffer
    public let format: AVAudioFormat

    public init() {
        let sampleRate: Double = 44100.0
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2)!
        self.format = format

        self.downbeatBuffer = Self.generateClickBuffer(
            frequency: 1760.0,
            duration: 0.04,
            amplitude: 0.9,
            format: format
        )

        self.regularBeatBuffer = Self.generateClickBuffer(
            frequency: 880.0,
            duration: 0.03,
            amplitude: 0.65,
            format: format
        )
    }

    private static func generateClickBuffer(
        frequency: Double,
        duration: Double,
        amplitude: Float,
        format: AVAudioFormat
    ) -> AVAudioPCMBuffer {
        let frameCount = AVAudioFrameCount(duration * format.sampleRate)
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buffer.frameLength = frameCount

        guard let left = buffer.floatChannelData?[0],
              let right = buffer.floatChannelData?[1] else {
            return buffer
        }

        let totalFrames = Double(frameCount)
        for i in 0..<Int(frameCount) {
            let t = Double(i) / format.sampleRate
            // Sine wave with steep exponential decay envelope
            let decay = exp(-t * 120.0)
            let sample = amplitude * Float(sin(2.0 * .pi * frequency * t) * decay)

            left[i] = sample
            right[i] = sample
        }

        return buffer
    }
}
