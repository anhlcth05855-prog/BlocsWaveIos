import Foundation
import AVFoundation

/// 3-Band Parametric EQ settings: Low Shelf (120Hz), Mid Peaking (1000Hz), High Shelf (7000Hz)
public struct EQSettings: Equatable, Codable, Sendable {
    public var lowGainDB: Float     // -12.0 to +12.0 dB
    public var midGainDB: Float     // -12.0 to +12.0 dB
    public var highGainDB: Float    // -12.0 to +12.0 dB
    public var isBypassed: Bool

    public static let lowFrequency: Float = 120.0
    public static let midFrequency: Float = 1000.0
    public static let highFrequency: Float = 7000.0
    public static let midBandwidth: Float = 1.0 // Octaves / Q

    public init(
        lowGainDB: Float = 0.0,
        midGainDB: Float = 0.0,
        highGainDB: Float = 0.0,
        isBypassed: Bool = false
    ) {
        self.lowGainDB = lowGainDB
        self.midGainDB = midGainDB
        self.highGainDB = highGainDB
        self.isBypassed = isBypassed
    }

    public static let flat = EQSettings()

    /// Applies these parameters directly to an AVAudioUnitEQ node.
    public func apply(to eqNode: AVAudioUnitEQ) {
        eqNode.bypass = isBypassed

        guard eqNode.bands.count >= 3 else { return }

        // Band 0: Low Shelf @ 120Hz
        let lowBand = eqNode.bands[0]
        lowBand.filterType = .lowShelf
        lowBand.frequency = Self.lowFrequency
        lowBand.gain = lowGainDB
        lowBand.bypass = false

        // Band 1: Parametric Mid @ 1000Hz
        let midBand = eqNode.bands[1]
        midBand.filterType = .parametric
        midBand.frequency = Self.midFrequency
        midBand.bandwidth = Self.midBandwidth
        midBand.gain = midGainDB
        midBand.bypass = false

        // Band 2: High Shelf @ 7000Hz
        let highBand = eqNode.bands[2]
        highBand.filterType = .highShelf
        highBand.frequency = Self.highFrequency
        highBand.gain = highGainDB
        highBand.bypass = false
    }
}
