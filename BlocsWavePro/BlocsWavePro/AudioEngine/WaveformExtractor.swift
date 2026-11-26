import Foundation
import AVFoundation
import Accelerate

/// Extracts visual waveform amplitude peaks from PCM audio buffers using Accelerate/vDSP.
public final class WaveformExtractor {

    /// Decimates a PCM buffer into a fixed count of normalized peaks [0.0 ... 1.0]
    public static func extractPeaks(from buffer: AVAudioPCMBuffer, targetCount: Int = 96) -> [Float] {
        guard let channelData = buffer.floatChannelData, buffer.frameLength > 0, targetCount > 0 else {
            return Array(repeating: 0.1, count: targetCount)
        }

        let totalFrames = Int(buffer.frameLength)
        let channelCount = Int(buffer.format.channelCount)
        let chunkSize = max(1, totalFrames / targetCount)

        var peaks = [Float](repeating: 0.0, count: targetCount)

        // If stereo or multi-channel, blend or take max channel
        for i in 0..<targetCount {
            let startFrame = i * chunkSize
            let endFrame = min(startFrame + chunkSize, totalFrames)
            let actualChunk = endFrame - startFrame
            guard actualChunk > 0 else { continue }

            var maxVal: Float = 0.0

            for ch in 0..<channelCount {
                let channelPointer = channelData[ch] + startFrame
                var chunkMax: Float = 0.0
                vDSP_maxmgv(channelPointer, 1, &chunkMax, vDSP_Length(actualChunk))
                if chunkMax > maxVal {
                    maxVal = chunkMax
                }
            }

            peaks[i] = maxVal
        }

        // Normalize peaks between 0.05 (for subtle baseline visibility) and 1.0
        var highestPeak: Float = 0.0
        vDSP_maxv(peaks, 1, &highestPeak, vDSP_Length(peaks.count))

        if highestPeak > 0.0001 {
            var scale = 1.0 / highestPeak
            var scaledPeaks = [Float](repeating: 0.0, count: targetCount)
            vDSP_vsmul(peaks, 1, &scale, &scaledPeaks, 1, vDSP_Length(targetCount))
            // Clamp and add min baseline
            return scaledPeaks.map { min(1.0, max(0.08, $0)) }
        }

        return Array(repeating: 0.1, count: targetCount)
    }

    /// Reads an audio file from URL and extracts waveform peaks
    public static func extractPeaks(from url: URL, targetCount: Int = 96) -> [Float] {
        do {
            let audioFile = try AVAudioFile(forReading: url)
            guard let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(audioFile.length)) else {
                return Array(repeating: 0.1, count: targetCount)
            }
            try audioFile.read(into: buffer)
            return extractPeaks(from: buffer, targetCount: targetCount)
        } catch {
            print("WaveformExtractor error reading URL: \(error.localizedDescription)")
            return Array(repeating: 0.1, count: targetCount)
        }
    }
}
