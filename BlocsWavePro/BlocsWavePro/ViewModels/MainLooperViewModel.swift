import Foundation
import SwiftUI
import AVFoundation
import Observation

/// Lightweight observable clock for playhead positions so only waveform canvases redraw at 30 FPS.
@Observable
public final class PlayheadClock {
    public var positions: [Double] = Array(repeating: 0.0, count: 8)
    public init() {}
}

/// Active modal sheet presented by MainView (avoids multiple .sheet conflicts in SwiftUI).
public enum ActiveSheet: Identifiable {
    case keyPicker
    case eqInspector
    case recording
    case exportDialog
    case shareSheet
    case soundBrowser

    public var id: Int {
        switch self {
        case .keyPicker: return 0
        case .eqInspector: return 1
        case .recording: return 2
        case .exportDialog: return 3
        case .shareSheet: return 4
        case .soundBrowser: return 5
        }
    }
}

/// Main ViewModel driving the Blocs Wave Pro interface using Swift's `@Observable` macro.
@Observable
public final class MainLooperViewModel {

    // Audio Engine
    private let engineController = AudioEngineController.shared

    // Core Domain State
    public var project: ProjectState
    public var tracks: [TrackModel] = []
    public var songSections: [SongSection] = SongSection.defaultSections
    public let playheadClock = PlayheadClock()

    // Active View States & Sheets
    public var selectedTrackIndex: Int = 0
    public var activeSheet: ActiveSheet? = nil
    public var selectedGenre: SoundGenre = .synthwave

    // Exported artifacts
    public var exportedFileURLs: [URL] = []
    public var isExporting: Bool = false
    public var exportProgressMessage: String = ""

    // Live Recording State
    public var liveMicLevel: Float = 0.0
    public var recordingBarsCount: Int = 4
    public var isLiveRecording: Bool = false
    public var recordingErrorMessage: String? = nil

    // Real-time Display Timer for 60 FPS Playhead Sync
    private var displayTimer: Timer?

    public init() {
        self.project = ProjectState(
            title: "Blocs Wave Session 01",
            masterBPM: 124.0,
            masterKey: MusicalKey(pitch: .c, mode: .minor),
            isPlaying: false
        )

        self.tracks = TrackModel.defaultTrackTemplates()

        setupEngine()
        setupAudioRecorderCallbacks()
        startDisplayTimer()
    }

    deinit {
        displayTimer?.invalidate()
    }

    // MARK: - Setup Engine

    private func setupEngine() {
        // Apply initial section A mute/volume presets immediately
        applySection(songSections[0])

        let initialBPM = project.masterBPM
        let defaultTypes: [TrackType] = [
            .kick, .snare, .hihat, .bass,
            .chords, .lead, .pluck, .vocalFX
        ]

        // Synthesize procedural audio loops off the main thread so the UI renders immediately
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            var generatedBuffers: [Int: AVAudioPCMBuffer] = [:]
            var extracted: [(Int, [Float], AVAudioFramePosition, Double)] = []

            for (idx, type) in defaultTypes.enumerated() {
                let buffer = AudioProceduralGenerator.generateTrackLoop(for: type, genre: .synthwave, bpm: initialBPM, bars: 2)
                generatedBuffers[idx] = buffer
                let peaks = WaveformExtractor.extractPeaks(from: buffer, targetCount: 96)
                let frames = AVAudioFramePosition(buffer.frameLength)
                let duration = Double(buffer.frameLength) / buffer.format.sampleRate
                extracted.append((idx, peaks, frames, duration))
            }

            DispatchQueue.main.async {
                guard let self = self else { return }
                self.engineController.applyPreGeneratedBuffers(generatedBuffers)
                for (idx, peaks, frames, duration) in extracted {
                    if idx < self.tracks.count {
                        self.tracks[idx].waveformPeaks = peaks
                        self.tracks[idx].isLoaded = true
                        self.tracks[idx].totalFrames = frames
                        self.tracks[idx].durationSeconds = duration
                    }
                }
            }
        }
    }

    public func handleAppDidBecomeActive() {
        engineController.ensureEngineRunning()
    }

    private func setupAudioRecorderCallbacks() {
        engineController.recorder.onLevelUpdate = { [weak self] level in
            self?.liveMicLevel = level
        }

        engineController.recorder.onRecordingFinished = { [weak self] buffer, peaks in
            guard let self = self else { return }
            self.isLiveRecording = false
            self.activeSheet = nil

            let targetIdx = self.project.recordingTrackIndex ?? self.selectedTrackIndex
            guard targetIdx < self.tracks.count else { return }

            self.tracks[targetIdx].waveformPeaks = peaks
            self.tracks[targetIdx].isUserRecorded = true
            self.tracks[targetIdx].isLoaded = true
            self.tracks[targetIdx].originalBPM = self.project.masterBPM
            self.tracks[targetIdx].name = "Mic Loop \(targetIdx + 1)"
            self.tracks[targetIdx].totalFrames = AVAudioFramePosition(buffer.frameLength)
            self.tracks[targetIdx].durationSeconds = Double(buffer.frameLength) / buffer.format.sampleRate

            self.engineController.loadRecordedBuffer(buffer, for: targetIdx, bpm: self.project.masterBPM)
        }
    }

    // MARK: - 60 FPS Playhead Display Timer

    private func startDisplayTimer() {
        displayTimer?.invalidate()
        displayTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            self?.updatePlayheads()
        }
        RunLoop.main.add(displayTimer!, forMode: .common)
    }

    private func updatePlayheads() {
        guard project.isPlaying else { return }
        let positions = engineController.getPlayheadPositions()
        for (i, pos) in positions.enumerated() {
            if i < playheadClock.positions.count {
                playheadClock.positions[i] = pos
            }
        }
    }

    // MARK: - Master Transport Controls

    public func togglePlayback() {
        if project.isPlaying {
            engineController.stopPlayback()
            project.isPlaying = false
        } else {
            engineController.startPlayback()
            project.isPlaying = true
        }
    }

    public func stopPlayback() {
        engineController.stopPlayback()
        project.isPlaying = false
        for i in 0..<playheadClock.positions.count {
            playheadClock.positions[i] = 0.0
        }
    }

    public func seekAll(to position: Double) {
        engineController.seekAll(to: position)
        for i in 0..<playheadClock.positions.count {
            playheadClock.positions[i] = position
        }
    }

    public func seekTrack(index: Int, position: Double) {
        guard index >= 0 && index < tracks.count else { return }
        if index < playheadClock.positions.count {
            playheadClock.positions[index] = position
        }
        engineController.trackNodes[index].seek(to: position)
    }

    // MARK: - BPM & Master Key

    public func setBPM(_ bpm: Double) {
        let clamped = min(200.0, max(60.0, bpm))
        project.masterBPM = clamped
        engineController.updateTempo(clamped)
    }

    public func incrementBPM(by delta: Double) {
        setBPM(project.masterBPM + delta)
    }

    public func handleTapTempo() {
        if let newBPM = engineController.recordTapTempo() {
            project.masterBPM = newBPM
        }
    }

    public func setMasterKey(_ key: MusicalKey) {
        project.masterKey = key
        engineController.updateKey(key)
    }

    public func toggleMetronome() {
        project.isMetronomeEnabled.toggle()
        engineController.isMetronomeEnabled = project.isMetronomeEnabled
    }

    // MARK: - Track Mixing & Parameters

    public func setVolume(for trackIndex: Int, volume: Float) {
        guard trackIndex >= 0 && trackIndex < tracks.count else { return }
        tracks[trackIndex].volume = volume
        engineController.setVolume(for: trackIndex, volume: volume)
    }

    public func setPan(for trackIndex: Int, pan: Float) {
        guard trackIndex >= 0 && trackIndex < tracks.count else { return }
        tracks[trackIndex].pan = pan
        engineController.setPan(for: trackIndex, pan: pan)
    }

    public func toggleMute(for trackIndex: Int) {
        guard trackIndex >= 0 && trackIndex < tracks.count else { return }
        tracks[trackIndex].isMuted.toggle()
        engineController.setMute(for: trackIndex, isMuted: tracks[trackIndex].isMuted)
    }

    public func toggleSolo(for trackIndex: Int) {
        guard trackIndex >= 0 && trackIndex < tracks.count else { return }
        tracks[trackIndex].isSolo.toggle()
        engineController.setSolo(for: trackIndex, isSolo: tracks[trackIndex].isSolo, tracks: tracks)
    }

    public func updateEQ(for trackIndex: Int, eq: EQSettings) {
        guard trackIndex >= 0 && trackIndex < tracks.count else { return }
        tracks[trackIndex].eqSettings = eq
        engineController.applyEQ(for: trackIndex, settings: eq)
    }

    // MARK: - Slice Mode

    public func toggleSliceMode(for trackIndex: Int) {
        guard trackIndex >= 0 && trackIndex < tracks.count else { return }
        tracks[trackIndex].sliceState.isSliceModeEnabled.toggle()

        if !tracks[trackIndex].sliceState.isSliceModeEnabled {
            tracks[trackIndex].sliceState.activeSliceIndex = nil
            engineController.exitSlice(for: trackIndex)
        }
    }

    public func triggerSlice(for trackIndex: Int, sliceIndex: Int) {
        guard trackIndex >= 0 && trackIndex < tracks.count else { return }
        tracks[trackIndex].sliceState.isSliceModeEnabled = true
        tracks[trackIndex].sliceState.activeSliceIndex = sliceIndex
        engineController.triggerSlice(for: trackIndex, sliceIndex: sliceIndex)
    }

    // MARK: - Song Sections (A, B, C, D)

    public func switchSection(to sectionID: SectionID) {
        project.activeSectionID = sectionID
        guard let section = songSections.first(where: { $0.id == sectionID }) else { return }
        applySection(section)
    }

    private func applySection(_ section: SongSection) {
        for (trackIdx, snapshot) in section.trackSnapshots {
            if trackIdx < tracks.count {
                tracks[trackIdx].isMuted = snapshot.isMuted
                tracks[trackIdx].volume = snapshot.volume
                engineController.setMute(for: trackIdx, isMuted: snapshot.isMuted)
                engineController.setVolume(for: trackIdx, volume: snapshot.volume)
            }
        }
    }

    // MARK: - Live Recording

    public func openRecordingModal(for trackIndex: Int) {
        project.recordingTrackIndex = trackIndex
        selectedTrackIndex = trackIndex
        recordingErrorMessage = nil
        activeSheet = .recording
    }

    public func startLiveRecording() {
        recordingErrorMessage = nil
        Task { @MainActor in
            let granted = await AudioSessionManager.shared.requestMicrophonePermission()
            guard granted else {
                self.recordingErrorMessage = "Microphone permission is required. Enable it in iPhone Settings > BlocsWavePro."
                return
            }

            do {
                try self.engineController.prepareForRecording()
                self.isLiveRecording = true
                try self.engineController.recorder.startRecording(
                    engine: self.engineController.engine,
                    bpm: self.project.masterBPM,
                    bars: self.recordingBarsCount
                )
            } catch {
                self.recordingErrorMessage = "Recording failed: \(error.localizedDescription)"
                self.isLiveRecording = false
            }
        }
    }

    public func stopLiveRecording() {
        engineController.recorder.stopRecording()
    }

    // MARK: - Exporting Mixdown & Stems

    public func exportMasterMixdown() {
        isExporting = true
        exportProgressMessage = "Rendering Master Mixdown..."

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            do {
                let mixdownURL = try AudioExporter.exportMasterMixdown(
                    tracks: self.tracks,
                    buffers: self.engineController.trackBuffers,
                    durationBars: 8,
                    masterBPM: self.project.masterBPM
                )
                DispatchQueue.main.async {
                    self.isExporting = false
                    self.exportedFileURLs = [mixdownURL]
                    self.activeSheet = .shareSheet
                }
            } catch {
                DispatchQueue.main.async {
                    self.isExporting = false
                    print("Export mixdown failed: \(error.localizedDescription)")
                }
            }
        }
    }

    public func exportAllStems() {
        isExporting = true
        exportProgressMessage = "Rendering 8 Stems..."

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            do {
                let stemURLs = try AudioExporter.exportStems(
                    tracks: self.tracks,
                    buffers: self.engineController.trackBuffers,
                    durationBars: 8,
                    masterBPM: self.project.masterBPM
                )
                DispatchQueue.main.async {
                    self.isExporting = false
                    self.exportedFileURLs = stemURLs
                    self.activeSheet = .shareSheet
                }
            } catch {
                DispatchQueue.main.async {
                    self.isExporting = false
                    print("Export stems failed: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Sound Presets & Multi-Genre Sound Packs

    public func applyGenrePack(_ genre: SoundGenre) {
        self.selectedGenre = genre
        let bpm = engineController.currentBPM
        let trackSnapshot = tracks.map { ($0.index, $0.type, $0.isUserRecorded) }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            var generated: [(Int, AVAudioPCMBuffer, [Float], AVAudioFramePosition, Double, String?)] = []

            for (idx, type, isUserRecorded) in trackSnapshot where !isUserRecorded {
                let buffer = AudioProceduralGenerator.generateTrackLoop(for: type, genre: genre, bpm: bpm, bars: 2)
                let peaks = WaveformExtractor.extractPeaks(from: buffer, targetCount: 96)
                let frames = AVAudioFramePosition(buffer.frameLength)
                let duration = Double(buffer.frameLength) / buffer.format.sampleRate
                let presetName = SoundLibrary.preset(type: type, genre: genre)?.name
                generated.append((idx, buffer, peaks, frames, duration, presetName))
            }

            DispatchQueue.main.async {
                guard let self = self, self.selectedGenre == genre else { return }
                for (idx, buffer, peaks, frames, duration, presetName) in generated {
                    self.engineController.applyPreGeneratedBuffer(buffer, for: idx, bpm: bpm)
                    if idx < self.tracks.count && !self.tracks[idx].isUserRecorded {
                        self.tracks[idx].waveformPeaks = peaks
                        self.tracks[idx].totalFrames = frames
                        self.tracks[idx].durationSeconds = duration
                        self.tracks[idx].originalBPM = bpm
                        if let name = presetName {
                            self.tracks[idx].name = name
                        }
                    }
                }
            }
        }
    }

    public func loadPreset(for trackIndex: Int, preset: SoundPreset) {
        guard trackIndex >= 0 && trackIndex < tracks.count else { return }
        let bpm = engineController.currentBPM
        tracks[trackIndex].isUserRecorded = false
        tracks[trackIndex].name = preset.name

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let buffer = AudioProceduralGenerator.generateTrackLoop(for: preset.trackType, genre: preset.genre, bpm: bpm, bars: 2)
            let peaks = WaveformExtractor.extractPeaks(from: buffer, targetCount: 96)
            let frames = AVAudioFramePosition(buffer.frameLength)
            let duration = Double(buffer.frameLength) / buffer.format.sampleRate

            DispatchQueue.main.async {
                guard let self = self, trackIndex < self.tracks.count else { return }
                self.engineController.applyPreGeneratedBuffer(buffer, for: trackIndex, bpm: bpm)
                self.tracks[trackIndex].waveformPeaks = peaks
                self.tracks[trackIndex].totalFrames = frames
                self.tracks[trackIndex].durationSeconds = duration
                self.tracks[trackIndex].originalBPM = bpm
            }
        }
    }

    public func auditionPreset(_ preset: SoundPreset) {
        engineController.auditionPreset(preset)
    }

    public func stopAudition() {
        engineController.stopAudition()
    }
}

