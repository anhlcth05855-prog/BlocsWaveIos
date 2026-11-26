import Foundation

/// Master state of the Blocs Wave project session.
public struct ProjectState: Equatable, Sendable {
    public var title: String
    public var masterBPM: Double // Range 60.0 ... 200.0
    public var masterKey: MusicalKey
    public var isPlaying: Bool
    public var isMetronomeEnabled: Bool
    public var metronomeVolume: Float
    public var activeSectionID: SectionID
    public var selectedTrackIndex: Int
    public var isRecording: Bool
    public var recordingTrackIndex: Int?
    public var targetRecordingBars: Int // 1, 2, 4, 8 bars

    public init(
        title: String = "Neon Sessions 01",
        masterBPM: Double = 124.0,
        masterKey: MusicalKey = MusicalKey(pitch: .c, mode: .minor),
        isPlaying: Bool = false,
        isMetronomeEnabled: Bool = false,
        metronomeVolume: Float = 0.7,
        activeSectionID: SectionID = .a,
        selectedTrackIndex: Int = 0,
        isRecording: Bool = false,
        recordingTrackIndex: Int? = nil,
        targetRecordingBars: Int = 4
    ) {
        self.title = title
        self.masterBPM = min(200.0, max(60.0, masterBPM))
        self.masterKey = masterKey
        self.isPlaying = isPlaying
        self.isMetronomeEnabled = isMetronomeEnabled
        self.metronomeVolume = metronomeVolume
        self.activeSectionID = activeSectionID
        self.selectedTrackIndex = selectedTrackIndex
        self.isRecording = isRecording
        self.recordingTrackIndex = recordingTrackIndex
        self.targetRecordingBars = targetRecordingBars
    }
}
