import Foundation
import AVFoundation
import Accelerate

/// Records live microphone input quantized to bar length based on Master BPM.
public final class AudioRecorder {
    private var engine: AVAudioEngine?
    private var isRecording = false
    private var recordedBuffer: AVAudioPCMBuffer?
    private var targetFrames: AVAudioFrameCount = 0
    private var collectedFrames: AVAudioFrameCount = 0

    // Callback handlers
    public var onLevelUpdate: ((Float) -> Void)?
    public var onRecordingFinished: ((AVAudioPCMBuffer, [Float]) -> Void)?

    // Destination format: 44.1kHz Stereo
    private let targetFormat = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 2)!

    public init() {}

    /// Starts recording for a quantized number of bars at the specified BPM
    public func startRecording(
        engine: AVAudioEngine,
        bpm: Double,
        bars: Int = 2
    ) throws {
        self.engine = engine
        let secondsPerBar = (60.0 / bpm) * 4.0
        let totalDuration = secondsPerBar * Double(bars)
        self.targetFrames = AVAudioFrameCount(totalDuration * targetFormat.sampleRate)
        self.collectedFrames = 0

        guard let buffer = AVAudioPCMBuffer(pcmFormat: targetFormat, frameCapacity: targetFrames) else {
            throw NSError(domain: "BlocsWavePro.AudioRecorder", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to allocate record buffer"])
        }
        buffer.frameLength = 0
        self.recordedBuffer = buffer

        let inputNode = engine.inputNode
        let inputFormat = inputNode.outputFormat(forBus: 0)
        guard inputFormat.sampleRate > 0 && inputFormat.channelCount > 0 else {
            throw NSError(domain: "BlocsWavePro.AudioRecorder", code: -2, userInfo: [NSLocalizedDescriptionKey: "Microphone input format is unavailable"])
        }

        // Ensure converter exists if formats differ
        let converter = AVAudioConverter(from: inputFormat, to: targetFormat)

        inputNode.removeTap(onBus: 0)
        self.isRecording = true

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputFormat) { [weak self] inputBuffer, _ in
            guard let self = self, self.isRecording, let recBuffer = self.recordedBuffer else { return }

            // Calculate peak level for VU meter
            if let channelData = inputBuffer.floatChannelData?[0] {
                var maxSample: Float = 0.0
                vDSP_maxmgv(channelData, 1, &maxSample, vDSP_Length(inputBuffer.frameLength))
                DispatchQueue.main.async {
                    self.onLevelUpdate?(min(1.0, maxSample * 1.5))
                }
            }

            // Convert and append to recording buffer
            let remainingFrames = self.targetFrames - self.collectedFrames
            if remainingFrames <= 0 {
                self.finishRecording()
                return
            }

            if let converter = converter {
                let ratio = self.targetFormat.sampleRate / inputFormat.sampleRate
                let outCapacity = max(1, AVAudioFrameCount(ceil(Double(inputBuffer.frameLength) * ratio)))
                guard let convertedBuffer = AVAudioPCMBuffer(pcmFormat: self.targetFormat, frameCapacity: outCapacity) else { return }
                var error: NSError?
                var isEnd = false

                let inputBlock: AVAudioConverterInputBlock = { _, outStatus in
                    if isEnd {
                        outStatus.pointee = .noDataNow
                        return nil
                    }
                    isEnd = true
                    outStatus.pointee = .haveData
                    return inputBuffer
                }

                let status = converter.convert(to: convertedBuffer, error: &error, withInputFrom: inputBlock)
                if status != .error && convertedBuffer.frameLength > 0 {
                    self.appendBuffer(convertedBuffer, into: recBuffer)
                }
            } else {
                self.appendBuffer(inputBuffer, into: recBuffer)
            }

            if self.collectedFrames >= self.targetFrames {
                self.finishRecording()
            }
        }
    }

    private func appendBuffer(_ source: AVAudioPCMBuffer, into destination: AVAudioPCMBuffer) {
        guard let srcL = source.floatChannelData?[0],
              let dstL = destination.floatChannelData?[0],
              let dstR = destination.floatChannelData?[1] else { return }

        let srcR = source.format.channelCount > 1 ? source.floatChannelData?[1] : srcL

        let framesToAppend = min(source.frameLength, destination.frameCapacity - destination.frameLength)
        let dstOffset = Int(destination.frameLength)

        for i in 0..<Int(framesToAppend) {
            dstL[dstOffset + i] = srcL[i]
            dstR[dstOffset + i] = srcR?[i] ?? srcL[i]
        }

        destination.frameLength += framesToAppend
        self.collectedFrames += framesToAppend
    }

    /// Stops recording early or when bar target is reached
    public func stopRecording() {
        finishRecording()
    }

    private func finishRecording() {
        guard isRecording else { return }
        isRecording = false

        if let engine = engine {
            engine.inputNode.removeTap(onBus: 0)
        }

        guard let buffer = recordedBuffer, buffer.frameLength > 0 else { return }

        // Extract waveform peaks immediately
        let peaks = WaveformExtractor.extractPeaks(from: buffer, targetCount: 96)

        DispatchQueue.main.async { [weak self] in
            self?.onRecordingFinished?(buffer, peaks)
        }
    }
}
