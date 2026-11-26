import SwiftUI

/// 8-Slice trigger pad bar allowing instantaneous jumping to any 1/8th subdivision of the loop.
public struct SliceOverlayView: View {
    public let track: TrackModel
    public let onSliceSelected: (Int) -> Void

    public init(track: TrackModel, onSliceSelected: @escaping (Int) -> Void) {
        self.track = track
        self.onSliceSelected = onSliceSelected
    }

    public var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<8, id: \.self) { sliceIndex in
                let isActive = track.sliceState.activeSliceIndex == sliceIndex

                Button {
                    onSliceSelected(sliceIndex)
                } label: {
                    Text("\(sliceIndex + 1)")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(isActive ? .black : .white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 24)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(isActive ? track.displayColor : AppColors.surfaceCard)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(isActive ? Color.white : track.displayColor.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: isActive ? track.displayColor.opacity(0.8) : .clear, radius: 4)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
