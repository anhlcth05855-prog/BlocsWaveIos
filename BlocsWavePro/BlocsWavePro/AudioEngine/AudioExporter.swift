import Foundation
import AVFoundation

/// Handles studio-grade offline rendering and export of Master Mixdown and Individual Track Stems to WAV files.
public final class AudioExporter {

    public struct ExportResult: Sendable {
        public let mixdownURL: URL?
        public let stemURLs: [URL]
    }

    /// Renders the complete master mixdown of all active tracks to a 44.1kHz 16-bit Stereo WAV file.
    public static func exportMasterMixdown(
        tracks: [TrackModel],
        buffers: [Int: AVAudioPCMBuffer],
        durationBars: Int = 4,
        masterBPM: Double = 124.0
    ) throws -> URL {
        let sampleRate: Double = 44100.0
        let totalSeconds = (60.0 / masterBPM) * 4.0 * Double(durationBars)
        let totalFrames = AVAudioFrameCount(totalSeconds * sampleRate)
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2)!

        guard let mixdownBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: totalFrames) else {
            throw NSError(domain: "AudioExporter", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to allocate mixdown buffer"])
        }
        mixdownBuffer.frameLength = totalFrames

        guard let mixL = mixdownBuffer.floatChannelData?[0],
              let mixR = mixdownBuffer.floatChannelData?[1] else {
            throw NSError(domain: "AudioExporter", code: -2, userInfo: [NSLocalizedDescriptionKey: "Buffer float channel data unavailable"])
        }

        // Initialize with silence
        for i in 0..<Int(totalFrames) {
            mixL[i] = 0.0
            mixR[i] = 0.0
        }

        // Check if any track is soloed
        let hasSolo = tracks.contains(where: { $0.isSolo })

        // Sum all audible tracks
        for track in tracks {
            if track.isMuted { continue }
            if hasSolo && !track.isSolo { continue }

            guard let trackBuffer = buffers[track.index],
                  let srcL = trackBuffer.floatChannelData?[0] else { continue }
            let srcR = trackBuffer.format.channelCount > 1 ? trackBuffer.floatChannelData?[1] : srcL
            let trackLength = Int(trackBuffer.frameLength)
            guard trackLength > 0 else { continue }

            let vol = track.volume
            // Pan law: constant power panning
            let pan = track.pan // -1.0 ... 1.0
            let leftGain = vol * Float(cos((Double(pan) + 1.0) * .pi / 4.0))
            let rightGain = vol * Float(sin((Double(pan) + 1.0) * .pi / 4.0))

            // EQ gain approximation for offline export
            let eqBoost = Float(pow(10.0, Double(track.eqSettings.midGainDB) / 20.0))

            for frame in 0..<Int(totalFrames) {
                let srcIndex = frame % trackLength
                let sampleL = (srcL[srcIndex]) * leftGain * eqBoost
                let sampleR = ((srcR?[srcIndex]) ?? srcL[srcIndex]) * rightGain * eqBoost

                mixL[frame] += sampleL
                mixR[frame] += sampleR
            }
        }

        // Soft-limiting / saturation to prevent harsh clipping
        for i in 0..<Int(totalFrames) {
            mixL[i] = tanh(mixL[i] * 0.9)
            mixR[i] = tanh(mixR[i] * 0.9)
        }

        // Save to WAV file
        let filename = "BlocsWave_Mixdown_\(Int(Date().timeIntervalSince1970)).wav"
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)

        try writeWAVFile(buffer: mixdownBuffer, destinationURL: outputURL)
        return outputURL
    }

    /// Renders individual track stems to separate 44.1kHz 16-bit WAV files
    public static func exportStems(
        tracks: [TrackModel],
        buffers: [Int: AVAudioPCMBuffer],
        durationBars: Int = 4,
        masterBPM: Double = 124.0
    ) throws -> [URL] {
        var stemURLs: [URL] = []
        let sampleRate: Double = 44100.0
        let totalSeconds = (60.0 / masterBPM) * 4.0 * Double(durationBars)
        let totalFrames = AVAudioFrameCount(totalSeconds * sampleRate)
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2)!

        for track in tracks {
            guard let trackBuffer = buffers[track.index],
                  let srcL = trackBuffer.floatChannelData?[0] else { continue }
            let srcR = trackBuffer.format.channelCount > 1 ? trackBuffer.floatChannelData?[1] : srcL
            let trackLength = Int(trackBuffer.frameLength)
            guard trackLength > 0 else { continue }

            guard let stemBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: totalFrames) else { continue }
            stemBuffer.frameLength = totalFrames

            guard let dstL = stemBuffer.floatChannelData?[0],
                  let dstR = stemBuffer.floatChannelData?[1] else { continue }

            let vol = track.volume
            let pan = track.pan
            let leftGain = vol * Float(cos((Double(pan) + 1.0) * .pi / 4.0))
            let rightGain = vol * Float(sin((Double(pan) + 1.0) * .pi / 4.0))

            for frame in 0..<Int(totalFrames) {
                let srcIndex = frame % trackLength
                dstL[frame] = (srcL[srcIndex]) * leftGain
                dstR[frame] = ((srcR?[srcIndex]) ?? srcL[srcIndex]) * rightGain
            }

            let sanitizedName = track.name.replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: " ", with: "_")
            let filename = "Stem_\(track.index + 1)_\(sanitizedName).wav"
            let stemURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)

            try writeWAVFile(buffer: stemBuffer, destinationURL: stemURL)
            stemURLs.append(stemURL)
        }

        return stemURLs
    }

    // MARK: - Standard 16-Bit Stereo WAV Writer

    /// Encodes an AVAudioPCMBuffer to a standard 44.1kHz 16-bit Stereo RIFF WAV file.
    public static func writeWAVFile(buffer: AVAudioPCMBuffer, destinationURL: URL) throws {
        guard let leftChannel = buffer.floatChannelData?[0] else {
            throw NSError(domain: "AudioExporter", code: -3, userInfo: [NSLocalizedDescriptionKey: "No audio data"])
        }
        let rightChannel = buffer.format.channelCount > 1 ? buffer.floatChannelData?[1] : leftChannel

        let numFrames = Int(buffer.frameLength)
        let numChannels: UInt16 = 2
        let sampleRate: UInt32 = 44100
        let bitsPerSample: UInt16 = 16
        let byteRate = sampleRate * UInt32(numChannels) * UInt32(bitsPerSample / 8)
        let blockAlign = numChannels * (bitsPerSample / 8)
        let dataSize = UInt32(numFrames * Int(numChannels) * 2)
        let chunkSize = 36 + dataSize

        var data = Data()

        // RIFF Header
        data.append("RIFF".data(using: .ascii)!)
        data.append(withUnsafeBytes(of: chunkSize.littleEndian) { Data($0) })
        data.append("WAVE".data(using: .ascii)!)

        // 'fmt ' Subchunk
        data.append("fmt ".data(using: .ascii)!)
        let subchunk1Size: UInt32 = 16
        data.append(withUnsafeBytes(of: subchunk1Size.littleEndian) { Data($0) })
        let audioFormat: UInt16 = 1 // PCM
        data.append(withUnsafeBytes(of: audioFormat.littleEndian) { Data($0) })
        data.append(withUnsafeBytes(of: numChannels.littleEndian) { Data($0) })
        data.append(withUnsafeBytes(of: sampleRate.littleEndian) { Data($0) })
        data.append(withUnsafeBytes(of: byteRate.littleEndian) { Data($0) })
        data.append(withUnsafeBytes(of: blockAlign.littleEndian) { Data($0) })
        data.append(withUnsafeBytes(of: bitsPerSample.littleEndian) { Data($0) })

        // 'data' Subchunk
        data.append("data".data(using: .ascii)!)
        data.append(withUnsafeBytes(of: dataSize.littleEndian) { Data($0) })

        // Interleaved 16-bit Samples
        for i in 0..<numFrames {
            let leftFloat = max(-1.0, min(1.0, leftChannel[i]))
            let rightFloat = max(-1.0, min(1.0, rightChannel?[i] ?? leftChannel[i]))

            let leftInt16 = Int16(leftFloat * 32767.0)
            let rightInt16 = Int16(rightFloat * 32767.0)

            data.append(withUnsafeBytes(of: leftInt16.littleEndian) { Data($0) })
            data.append(withUnsafeBytes(of: rightInt16.littleEndian) { Data($0) })
        }

        try data.write(to: destinationURL, options: .atomic)
    }
}
