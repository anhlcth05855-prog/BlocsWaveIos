import Foundation
import AVFoundation

/// Manages the iOS AVAudioSession for low-latency live audio looping and recording.
public final class AudioSessionManager {
    public static let shared = AudioSessionManager()

    private init() {}

    /// Configures audio session for ultra-low latency playback and live microphone input.
    public func configureSession() throws {
        let session = AVAudioSession.sharedInstance()

        // Use playAndRecord with defaultToSpeaker and allowBluetooth
        var options: AVAudioSession.CategoryOptions = [.defaultToSpeaker, .allowBluetoothA2DP]
        #if !targetEnvironment(simulator)
        options.insert(.allowBluetooth)
        #endif

        try session.setCategory(.playAndRecord, mode: .default, options: options)

        // Use 23ms buffer (~1024 frames @ 44.1kHz) for glitch-free multi-track DSP playback
        try? session.setPreferredIOBufferDuration(0.023)
        try? session.setPreferredSampleRate(44100.0)

        try session.setActive(true, options: .notifyOthersOnDeactivation)
    }

    /// Requests microphone recording permission asynchronously
    public func requestMicrophonePermission() async -> Bool {
        if #available(iOS 17.0, *) {
            return await AVAudioApplication.requestRecordPermission()
        } else {
            return await withCheckedContinuation { continuation in
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            }
        }
    }

    /// Verifies if microphone permission is currently granted
    public var hasMicrophonePermission: Bool {
        if #available(iOS 17.0, *) {
            return AVAudioApplication.shared.recordPermission == .granted
        } else {
            return AVAudioSession.sharedInstance().recordPermission == .granted
        }
    }
}
