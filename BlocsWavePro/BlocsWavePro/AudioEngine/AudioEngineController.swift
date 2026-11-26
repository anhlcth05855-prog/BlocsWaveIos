import Foundation
import AVFoundation

/// Central Audio Engine Controller coordinating AVAudioEngine, 8 track channels, metronome, and audio clock.
public final class AudioEngineController {
    public static let shared = AudioEngineController()

    // AVAudioEngine Graph
    public let engine = AVAudioEngine()
    public let masterMixer = AVAudioMixerNode()

    // 8 Independent Track Audio Nodes
    public private(set) var trackNodes: [AudioTrackNode] = []

    // Metronome
    private let metronomePlayer = AVAudioPlayerNode()
    private let metronomeGenerator = MetronomeGenerator()
    private var metronomeTimer: DispatchSourceTimer?
    public var isMetronomeEnabled: Bool = false
    public var metronomeVolume: Float = 0.75 {
        didSet { metronomePlayer.volume = metronomeVolume }
    }

    // Audition Preview Player
    private let auditionPlayer = AVAudioPlayerNode()

    // Audio Buffers Cache
    public private(set) var trackBuffers: [Int: AVAudioPCMBuffer] = [:]

    // State
    public private(set) var isRunning: Bool = false
    public private(set) var isPlaying: Bool = false
    public private(set) var currentBPM: Double = 124.0
    public private(set) var currentKey: MusicalKey = MusicalKey(pitch: .c, mode: .minor)

    // Tap Tempo Buffer
    private var tapTimestamps: [Date] = []

    // Live Recorder
    public let recorder = AudioRecorder()

    private init() {
        setupGraph()
    }

    /// Re-activates audio session and restarts AVAudioEngine when returning from background.
    public func ensureEngineRunning() {
        do {
            try AudioSessionManager.shared.configureSession()
            if !engine.isRunning {
                try engine.start()
            }
            isRunning = engine.isRunning
        } catch {
            print("Failed to resume AVAudioEngine: \(error.localizedDescription)")
        }
    }

    // MARK: - Engine Setup

    private func setupGraph() {
        try? AudioSessionManager.shared.configureSession()

        let sampleRate: Double = 44100.0
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2)!

        engine.attach(masterMixer)
        engine.connect(masterMixer, to: engine.mainMixerNode, format: format)

        // Attach & connect Metronome
        engine.attach(metronomePlayer)
        engine.connect(metronomePlayer, to: masterMixer, format: format)
        metronomePlayer.volume = metronomeVolume

        // Attach & connect Audition Player
        engine.attach(auditionPlayer)
        engine.connect(auditionPlayer, to: masterMixer, format: format)
        auditionPlayer.volume = 0.85

        // Create 8 AudioTrackNodes
        for i in 0..<8 {
            let trackNode = AudioTrackNode(index: i)
            trackNode.attachAndConnect(to: engine, masterMixer: masterMixer, format: format)
            trackNodes.append(trackNode)
        }

        do {
            engine.prepare()
            try engine.start()
            isRunning = true
        } catch {
            print("Failed to start AVAudioEngine: \(error.localizedDescription)")
        }
    }

    /// Prepares the audio session and restarts the engine if needed so inputNode has a valid hardware format.
    public func prepareForRecording() throws {
        try AudioSessionManager.shared.configureSession()
        let inputFormat = engine.inputNode.outputFormat(forBus: 0)
        if !engine.isRunning || inputFormat.sampleRate <= 0 || inputFormat.channelCount == 0 {
            if engine.isRunning {
                engine.stop()
            }
            engine.prepare()
            try engine.start()
            isRunning = engine.isRunning
        }
    }

    // MARK: - Initializing Demo Tracks

    /// Populates all 8 tracks with pre-generated buffers (safe to call on main thread after background synthesis)
    public func applyPreGeneratedBuffers(_ buffers: [Int: AVAudioPCMBuffer]) {
        for (idx, buffer) in buffers {
            guard idx < trackNodes.count else { continue }
            trackBuffers[idx] = buffer
            trackNodes[idx].loadBuffer(
                buffer,
                originalBPM: currentBPM,
                originalKey: MusicalKey(pitch: .c, mode: .minor)
            )
        }

        updateTempo(currentBPM)
        updateKey(currentKey)

        if isPlaying {
            for node in trackNodes {
                node.play()
            }
        }
    }

    // MARK: - Sound Preset & Sound Bank Management

    /// Auditions an individual sound preset in isolation
    public func auditionPreset(_ preset: SoundPreset) {
        ensureEngineRunning()
        stopAudition()
        let buffer = AudioProceduralGenerator.generateTrackLoop(for: preset.trackType, genre: preset.genre, bpm: currentBPM, bars: 2)
        auditionPlayer.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
        auditionPlayer.play()
    }

    /// Stops any running preset audition
    public func stopAudition() {
        auditionPlayer.stop()
    }

    /// Loads an individual sound preset into a specific track
    public func loadPreset(_ preset: SoundPreset, for trackIndex: Int) {
        guard trackIndex >= 0 && trackIndex < trackNodes.count else { return }
        let buffer = AudioProceduralGenerator.generateTrackLoop(for: preset.trackType, genre: preset.genre, bpm: currentBPM, bars: 2)
        trackBuffers[trackIndex] = buffer
        trackNodes[trackIndex].loadBuffer(
            buffer,
            originalBPM: currentBPM,
            originalKey: currentKey
        )
        trackNodes[trackIndex].updateTempo(masterBPM: currentBPM)
        trackNodes[trackIndex].updatePitch(masterKey: currentKey)
        if isPlaying {
            trackNodes[trackIndex].play()
        }
    }

    /// Applies a complete genre sound pack across all tracks
    public func applyGenrePack(_ genre: SoundGenre, tracks: [TrackModel]) {
        for (idx, track) in tracks.enumerated() {
            if !track.isUserRecorded && idx < trackNodes.count {
                let buffer = AudioProceduralGenerator.generateTrackLoop(for: track.type, genre: genre, bpm: currentBPM, bars: 2)
                trackBuffers[idx] = buffer
                trackNodes[idx].loadBuffer(
                    buffer,
                    originalBPM: currentBPM,
                    originalKey: currentKey
                )
                trackNodes[idx].updateTempo(masterBPM: currentBPM)
                trackNodes[idx].updatePitch(masterKey: currentKey)
                if isPlaying {
                    trackNodes[idx].play()
                }
            }
        }
    }

    // MARK: - Master Transport (Play / Stop)

    public func startPlayback() {
        guard !isPlaying else { return }

        ensureEngineRunning()

        for node in trackNodes {
            node.play()
        }

        metronomePlayer.play()
        startMetronomeTimer()
        isPlaying = true
    }

    public func stopPlayback() {
        guard isPlaying else { return }

        for node in trackNodes {
            node.stop()
        }

        metronomePlayer.stop()
        stopMetronomeTimer()
        isPlaying = false
    }

    public func seekAll(to normalizedPosition: Double) {
        for node in trackNodes {
            node.seek(to: normalizedPosition)
        }
    }

    // MARK: - Real-time Tempo Stretching

    public func updateTempo(_ newBPM: Double) {
        self.currentBPM = min(200.0, max(60.0, newBPM))
        for node in trackNodes {
            node.updateTempo(masterBPM: self.currentBPM)
        }

        // Reschedule metronome timer if currently playing
        if isPlaying {
            startMetronomeTimer()
        }
    }

    // MARK: - Master Key Harmonization

    public func updateKey(_ newKey: MusicalKey) {
        self.currentKey = newKey
        for node in trackNodes {
            node.updatePitch(masterKey: newKey)
        }
    }

    // MARK: - Track Parameter Adjustments

    public func setVolume(for trackIndex: Int, volume: Float) {
        guard trackIndex >= 0 && trackIndex < trackNodes.count else { return }
        trackNodes[trackIndex].rawVolume = max(0.0, min(1.0, volume))
    }

    public func setPan(for trackIndex: Int, pan: Float) {
        guard trackIndex >= 0 && trackIndex < trackNodes.count else { return }
        trackNodes[trackIndex].setPan(pan)
    }

    public func setMute(for trackIndex: Int, isMuted: Bool) {
        guard trackIndex >= 0 && trackIndex < trackNodes.count else { return }
        trackNodes[trackIndex].isMuted = isMuted
    }

    public func setSolo(for trackIndex: Int, isSolo: Bool, tracks: [TrackModel]) {
        guard trackIndex >= 0 && trackIndex < trackNodes.count else { return }
        trackNodes[trackIndex].isSolo = isSolo

        let hasAnySolo = tracks.contains(where: { $0.isSolo }) || isSolo
        for node in trackNodes {
            node.isGlobalSoloActive = hasAnySolo
        }
    }

    public func applyEQ(for trackIndex: Int, settings: EQSettings) {
        guard trackIndex >= 0 && trackIndex < trackNodes.count else { return }
        trackNodes[trackIndex].applyEQ(settings)
    }

    // MARK: - Slice Mode

    public func triggerSlice(for trackIndex: Int, sliceIndex: Int) {
        guard trackIndex >= 0 && trackIndex < trackNodes.count else { return }
        trackNodes[trackIndex].triggerSlice(index: sliceIndex)
    }

    public func exitSlice(for trackIndex: Int) {
        guard trackIndex >= 0 && trackIndex < trackNodes.count else { return }
        trackNodes[trackIndex].exitSliceMode()
    }

    // MARK: - Tap Tempo

    /// Records a user finger tap and computes the corresponding BPM
    public func recordTapTempo() -> Double? {
        let now = Date()
        tapTimestamps.append(now)

        // Retain taps within the last 3.0 seconds
        tapTimestamps = tapTimestamps.filter { now.timeIntervalSince($0) <= 3.0 }

        guard tapTimestamps.count >= 3 else { return nil }

        // Compute average delta between taps
        var intervals: [TimeInterval] = []
        for i in 1..<tapTimestamps.count {
            intervals.append(tapTimestamps[i].timeIntervalSince(tapTimestamps[i - 1]))
        }

        let avgInterval = intervals.reduce(0.0, +) / Double(intervals.count)
        guard avgInterval > 0.05 else { return nil }

        let calculatedBPM = 60.0 / avgInterval
        let clampedBPM = min(200.0, max(60.0, round(calculatedBPM)))

        updateTempo(clampedBPM)
        return clampedBPM
    }

    // MARK: - Metronome Timing

    private var beatCount: Int = 0

    private func startMetronomeTimer() {
        stopMetronomeTimer()

        let queue = DispatchQueue(label: "com.blocswavepro.metronome", qos: .userInteractive)
        let timer = DispatchSource.makeTimerSource(queue: queue)
        let intervalMs = Int((60.0 / currentBPM) * 1000.0)

        timer.schedule(deadline: .now(), repeating: .milliseconds(intervalMs))
        timer.setEventHandler { [weak self] in
            guard let self = self else { return }
            self.tickMetronome()
        }
        timer.resume()
        self.metronomeTimer = timer
    }

    private func stopMetronomeTimer() {
        metronomeTimer?.cancel()
        metronomeTimer = nil
        beatCount = 0
    }

    private func tickMetronome() {
        guard isMetronomeEnabled, isPlaying else { return }

        let isDownbeat = (beatCount % 4 == 0)
        let clickBuffer = isDownbeat ? metronomeGenerator.downbeatBuffer : metronomeGenerator.regularBeatBuffer

        metronomePlayer.scheduleBuffer(clickBuffer, at: nil, options: .interrupts, completionHandler: nil)
        beatCount += 1
    }

    // MARK: - Playhead Positions

    public func getPlayheadPositions() -> [Double] {
        trackNodes.map { $0.currentPlayheadPosition() }
    }

    // MARK: - Loading Recorded Audio

    public func loadRecordedBuffer(_ buffer: AVAudioPCMBuffer, for trackIndex: Int, bpm: Double) {
        guard trackIndex >= 0 && trackIndex < trackNodes.count else { return }
        trackBuffers[trackIndex] = buffer
        trackNodes[trackIndex].loadBuffer(buffer, originalBPM: bpm, originalKey: currentKey)
        trackNodes[trackIndex].updateTempo(masterBPM: currentBPM)
        trackNodes[trackIndex].updatePitch(masterKey: currentKey)
    }
}
