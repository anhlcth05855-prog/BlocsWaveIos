import Foundation
import AVFoundation

/// Encapsulates the audio node chain for an individual track:
/// PlayerNode -> TimePitchNode -> EQNode -> TrackMixerNode
public final class AudioTrackNode {
    public let index: Int
    public let playerNode = AVAudioPlayerNode()
    public let timePitchNode = AVAudioUnitTimePitch()
    public let eqNode = AVAudioUnitEQ(numberOfBands: 3)
    public let mixerNode = AVAudioMixerNode()

    // Internal Audio Buffer
    public private(set) var currentBuffer: AVAudioPCMBuffer?
    public private(set) var originalBPM: Double = 124.0
    public private(set) var originalKey: MusicalKey = MusicalKey(pitch: .c, mode: .minor)

    // Slicing & Playback offsets
    private var isPlaying = false
    private var isSliceActive = false
    private var currentSliceIndex: Int?
    private var startFrameOffset: AVAudioFramePosition = 0
    private var scheduledFramesCount: AVAudioFrameCount = 0

    // Volume & Solo logic
    public var rawVolume: Float = 0.85 {
        didSet { updateEffectiveVolume() }
    }
    public var isMuted: Bool = false {
        didSet { updateEffectiveVolume() }
    }
    public var isSolo: Bool = false {
        didSet { updateEffectiveVolume() }
    }
    public var isGlobalSoloActive: Bool = false {
        didSet { updateEffectiveVolume() }
    }

    public init(index: Int) {
        self.index = index
        setupEQDefaults()
        updateEffectiveVolume()
    }

    private func setupEQDefaults() {
        EQSettings.flat.apply(to: eqNode)
        timePitchNode.bypass = true
    }

    /// Attaches and connects all nodes in this track's chain to the master mixer.
    public func attachAndConnect(to engine: AVAudioEngine, masterMixer: AVAudioMixerNode, format: AVAudioFormat) {
        engine.attach(playerNode)
        engine.attach(timePitchNode)
        engine.attach(eqNode)
        engine.attach(mixerNode)

        // Connect chain: Player -> TimePitch -> EQ -> Mixer -> Master
        engine.connect(playerNode, to: timePitchNode, format: format)
        engine.connect(timePitchNode, to: eqNode, format: format)
        engine.connect(eqNode, to: mixerNode, format: format)
        engine.connect(mixerNode, to: masterMixer, format: format)
    }

    /// Loads a PCM buffer into the track
    public func loadBuffer(
        _ buffer: AVAudioPCMBuffer,
        originalBPM: Double,
        originalKey: MusicalKey
    ) {
        self.currentBuffer = buffer
        self.originalBPM = originalBPM
        self.originalKey = originalKey
        self.startFrameOffset = 0
        self.scheduledFramesCount = buffer.frameLength

        if isPlaying {
            schedulePlayback(fromNormalizedPosition: 0.0)
        }
    }

    // MARK: - Playback Control

    /// Starts playback from current position or begins loop
    public func play() {
        guard currentBuffer != nil else { return }

        if !isPlaying {
            isPlaying = true
            schedulePlayback(fromNormalizedPosition: 0.0)
        }

        if !playerNode.isPlaying {
            playerNode.play()
        }
    }

    /// Stops playback and resets state
    public func stop() {
        playerNode.stop()
        isPlaying = false
    }

    /// Pauses playback
    public func pause() {
        playerNode.pause()
        isPlaying = false
    }

    /// Seeks to a normalized position (0.0 ... 1.0) and reschedules playback smoothly
    public func seek(to normalizedPosition: Double) {
        guard currentBuffer != nil else { return }
        let clamped = max(0.0, min(0.999, normalizedPosition))
        schedulePlayback(fromNormalizedPosition: clamped)
    }

    /// Schedules full loop or slice loop playback
    public func schedulePlayback(fromNormalizedPosition startPos: Double) {
        guard let buffer = currentBuffer, buffer.frameLength > 0 else { return }

        playerNode.stop()

        if isSliceActive, let sliceIdx = currentSliceIndex {
            // Schedule slice loop (1/8th of loop)
            let sliceWidth = 1.0 / 8.0
            let sliceStartFraction = Double(sliceIdx) * sliceWidth
            let sliceLengthFraction = sliceWidth

            let sliceStartFrame = AVAudioFramePosition(Double(buffer.frameLength) * sliceStartFraction)
            let sliceFrameCount = AVAudioFrameCount(Double(buffer.frameLength) * sliceLengthFraction)

            scheduleSubBuffer(from: buffer, startFrame: sliceStartFrame, frameCount: sliceFrameCount, loop: true)
        } else {
            // Full loop scheduling
            if startPos <= 0.001 {
                // Schedule continuous full loop
                playerNode.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
            } else {
                // Schedule from seek point to end, then loop continuously
                let startFrame = AVAudioFramePosition(Double(buffer.frameLength) * startPos)
                let remainingFrames = AVAudioFrameCount(AVAudioFramePosition(buffer.frameLength) - startFrame)

                scheduleSubBuffer(from: buffer, startFrame: startFrame, frameCount: remainingFrames, loop: false) { [weak self] in
                    guard let self = self, self.isPlaying, !self.isSliceActive else { return }
                    // Followed immediately by infinite loop
                    self.playerNode.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
                }
            }
        }

        if isPlaying && !playerNode.isPlaying {
            playerNode.play()
        }
    }

    /// Schedules a slice sub-buffer
    private func scheduleSubBuffer(
        from sourceBuffer: AVAudioPCMBuffer,
        startFrame: AVAudioFramePosition,
        frameCount: AVAudioFrameCount,
        loop: Bool,
        completion: (() -> Void)? = nil
    ) {
        guard frameCount > 0,
              let subBuffer = createSubBuffer(from: sourceBuffer, startFrame: startFrame, frameLength: frameCount) else {
            return
        }

        let options: AVAudioPlayerNodeBufferOptions = loop ? .loops : []
        playerNode.scheduleBuffer(subBuffer, at: nil, options: options) {
            completion?()
        }
    }

    /// Extracts a sub-buffer slice from an AVAudioPCMBuffer
    private func createSubBuffer(
        from source: AVAudioPCMBuffer,
        startFrame: AVAudioFramePosition,
        frameLength: AVAudioFrameCount
    ) -> AVAudioPCMBuffer? {
        guard let dest = AVAudioPCMBuffer(pcmFormat: source.format, frameCapacity: frameLength) else {
            return nil
        }
        dest.frameLength = frameLength

        let channelCount = Int(source.format.channelCount)
        guard let srcData = source.floatChannelData,
              let dstData = dest.floatChannelData else {
            return nil
        }

        let startInt = Int(startFrame)
        let lengthInt = Int(frameLength)

        for ch in 0..<channelCount {
            let srcChannel = srcData[ch]
            let dstChannel = dstData[ch]
            for i in 0..<lengthInt {
                let srcIndex = startInt + i
                if srcIndex < Int(source.frameLength) {
                    dstChannel[i] = srcChannel[srcIndex]
                } else {
                    dstChannel[i] = 0.0
                }
            }
        }

        return dest
    }

    // MARK: - Slice Mode Trigger

    /// Activates slice mode and triggers a specific slice (0..<8)
    public func triggerSlice(index: Int) {
        guard index >= 0 && index < 8 else { return }
        self.isSliceActive = true
        self.currentSliceIndex = index
        schedulePlayback(fromNormalizedPosition: 0.0)
    }

    /// Exits slice mode back to full loop
    public func exitSliceMode() {
        self.isSliceActive = false
        self.currentSliceIndex = nil
        schedulePlayback(fromNormalizedPosition: 0.0)
    }

    // MARK: - Tempo & Pitch Processing

    /// Synchronizes tempo with Master BPM via real-time rate stretching
    public func updateTempo(masterBPM: Double) {
        guard originalBPM > 0 else { return }
        let rateRatio = Float(masterBPM / originalBPM)
        // AVAudioUnitTimePitch supports rate between 1/32 (0.03125) and 32.0
        let clampedRate = max(0.25, min(4.0, rateRatio))
        timePitchNode.rate = clampedRate
        updateTimePitchBypass()
    }

    /// Harmonizes track key with Master Key
    public func updatePitch(masterKey: MusicalKey) {
        let semitones = masterKey.semitones(from: originalKey)
        // AVAudioUnitTimePitch pitch is in cents (-2400 to 2400)
        let cents = Float(semitones * 100)
        timePitchNode.pitch = cents
        updateTimePitchBypass()
    }

    private func updateTimePitchBypass() {
        let isNeutralRate = abs(timePitchNode.rate - 1.0) < 0.001
        let isNeutralPitch = abs(timePitchNode.pitch) < 1.0
        timePitchNode.bypass = isNeutralRate && isNeutralPitch
    }

    // MARK: - Parametric EQ & Volume / Pan

    public func applyEQ(_ settings: EQSettings) {
        settings.apply(to: eqNode)
    }

    public func setPan(_ pan: Float) {
        mixerNode.pan = max(-1.0, min(1.0, pan))
    }

    private func updateEffectiveVolume() {
        if isMuted {
            mixerNode.outputVolume = 0.0
            return
        }

        if isGlobalSoloActive {
            mixerNode.outputVolume = isSolo ? rawVolume : 0.0
            return
        }

        mixerNode.outputVolume = rawVolume
    }

    // MARK: - Current Playhead Time Tracking

    /// Computes normalized position (0.0 ... 1.0) for drawing the playhead
    public func currentPlayheadPosition() -> Double {
        guard let buffer = currentBuffer, buffer.frameLength > 0, playerNode.isPlaying else {
            return 0.0
        }

        guard let nodeTime = playerNode.lastRenderTime,
              let playerTime = playerNode.playerTime(forNodeTime: nodeTime) else {
            return 0.0
        }

        if isSliceActive, let sliceIdx = currentSliceIndex {
            let sliceWidth = 1.0 / 8.0
            let sliceBase = Double(sliceIdx) * sliceWidth
            let sliceFrames = Double(buffer.frameLength) * sliceWidth
            guard sliceFrames > 0 else { return sliceBase }

            let sampleTime = Double(playerTime.sampleTime)
            let rawSliceProgress = (sampleTime.truncatingRemainder(dividingBy: sliceFrames)) / sliceFrames
            let sliceProgress = max(0.0, min(1.0, rawSliceProgress))
            return sliceBase + (sliceProgress * sliceWidth)
        } else {
            let totalFrames = Double(buffer.frameLength)
            let sampleTime = Double(playerTime.sampleTime)
            let progress = (sampleTime.truncatingRemainder(dividingBy: totalFrames)) / totalFrames
            return max(0.0, min(1.0, progress))
        }
    }
}
