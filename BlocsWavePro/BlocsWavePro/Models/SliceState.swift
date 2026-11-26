import Foundation
import AVFoundation

/// Represents a single slice boundary inside an audio loop.
public struct SliceRange: Equatable, Codable, Sendable {
    public let index: Int
    public let startFraction: Double // 0.0 to 1.0
    public let endFraction: Double   // 0.0 to 1.0

    public init(index: Int, startFraction: Double, endFraction: Double) {
        self.index = index
        self.startFraction = startFraction
        self.endFraction = endFraction
    }

    public func sampleRange(totalFrames: AVAudioFramePosition) -> (start: AVAudioFramePosition, end: AVAudioFramePosition) {
        let start = AVAudioFramePosition(Double(totalFrames) * startFraction)
        let end = AVAudioFramePosition(Double(totalFrames) * endFraction)
        return (start, min(end, totalFrames))
    }
}

/// State for 8-slice looper mode.
public struct SliceState: Equatable, Codable, Sendable {
    public var isSliceModeEnabled: Bool
    public var activeSliceIndex: Int? // nil = whole loop, 0..<8 = slice loop
    public var totalSlices: Int

    public init(
        isSliceModeEnabled: Bool = false,
        activeSliceIndex: Int? = nil,
        totalSlices: Int = 8
    ) {
        self.isSliceModeEnabled = isSliceModeEnabled
        self.activeSliceIndex = activeSliceIndex
        self.totalSlices = totalSlices
    }

    /// Generates the standard 8 equal slices across normalized [0.0, 1.0] loop length.
    public var slices: [SliceRange] {
        guard totalSlices > 0 else { return [] }
        let sliceWidth = 1.0 / Double(totalSlices)
        return (0..<totalSlices).map { i in
            let start = Double(i) * sliceWidth
            let end = Double(i + 1) * sliceWidth
            return SliceRange(index: i, startFraction: start, endFraction: end)
        }
    }

    /// Retrieves active slice range if a slice is currently targeted.
    public var activeSlice: SliceRange? {
        guard isSliceModeEnabled, let idx = activeSliceIndex, idx >= 0 && idx < totalSlices else {
            return nil
        }
        return slices[idx]
    }
}
