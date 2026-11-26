import SwiftUI

/// High-performance Canvas-rendered waveform supporting 60 FPS playhead, touch scrubbing, and 8-slice mode.
public struct TouchableWaveformCanvas: View {
    public let track: TrackModel
    public let onSeek: (Double) -> Void
    public let onSliceTapped: (Int) -> Void

    @State private var isDragging: Bool = false
    @State private var dragPosition: Double = 0.0

    public init(
        track: TrackModel,
        onSeek: @escaping (Double) -> Void,
        onSliceTapped: @escaping (Int) -> Void
    ) {
        self.track = track
        self.onSeek = onSeek
        self.onSliceTapped = onSliceTapped
    }

    public var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height

            ZStack {
                // Waveform Canvas
                Canvas { context, size in
                    drawWaveform(context: context, size: size)
                    if track.sliceState.isSliceModeEnabled {
                        drawSliceOverlays(context: context, size: size)
                    }
                    drawPlayhead(context: context, size: size)
                }
                .background(AppColors.surfaceDark.opacity(0.85))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(track.displayColor.opacity(0.35), lineWidth: 1)
                )

                // Touch & Gesture Interaction Layer
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                guard width > 0 else { return }
                                isDragging = true
                                let clampedX = max(0, min(width, value.location.x))
                                let progress = Double(clampedX / width)
                                dragPosition = progress

                                if track.sliceState.isSliceModeEnabled {
                                    let sliceIndex = min(7, max(0, Int(progress * 8.0)))
                                    onSliceTapped(sliceIndex)
                                } else {
                                    onSeek(progress)
                                }
                            }
                            .onEnded { value in
                                isDragging = false
                                guard width > 0 else { return }
                                let clampedX = max(0, min(width, value.location.x))
                                let progress = Double(clampedX / width)
                                if !track.sliceState.isSliceModeEnabled {
                                    onSeek(progress)
                                }
                            }
                    )
            }
        }
    }

    // MARK: - Drawing Routines

    private func drawWaveform(context: GraphicsContext, size: CGSize) {
        let peaks = track.waveformPeaks.isEmpty ? TrackModel.generateMockPeaks(count: 64, style: track.type) : track.waveformPeaks
        let barCount = peaks.count
        guard barCount > 0 else { return }

        let totalSpacing = CGFloat(barCount - 1) * 2.0
        let barWidth = max(2.0, (size.width - totalSpacing) / CGFloat(barCount))
        let centerY = size.height / 2.0
        let color = track.displayColor

        for i in 0..<barCount {
            let peak = CGFloat(peaks[i])
            let barHeight = max(4.0, (size.height * 0.88) * peak)
            let x = CGFloat(i) * (barWidth + 2.0)
            let y = centerY - (barHeight / 2.0)

            let rect = CGRect(x: x, y: y, width: barWidth, height: barHeight)
            let path = Path(roundedRect: rect, cornerRadius: barWidth / 2.0)

            // Neon gradient shading
            let gradient = Gradient(colors: [
                color.opacity(0.95),
                color.opacity(0.65),
                color.opacity(0.3)
            ])

            context.fill(
                path,
                with: .linearGradient(
                    gradient,
                    startPoint: CGPoint(x: x, y: y),
                    endPoint: CGPoint(x: x, y: y + barHeight)
                )
            )
        }
    }

    private func drawSliceOverlays(context: GraphicsContext, size: CGSize) {
        let sliceWidth = size.width / 8.0

        // Highlight active slice
        if let activeIdx = track.sliceState.activeSliceIndex {
            let activeRect = CGRect(x: CGFloat(activeIdx) * sliceWidth, y: 0, width: sliceWidth, height: size.height)
            context.fill(Path(activeRect), with: .color(track.displayColor.opacity(0.22)))
            context.stroke(Path(activeRect), with: .color(track.displayColor.opacity(0.9)), lineWidth: 1.5)
        }

        // Draw dotted slice dividers (1..7)
        for i in 1..<8 {
            let x = CGFloat(i) * sliceWidth
            var path = Path()
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: size.height))

            let dashedStyle = StrokeStyle(lineWidth: 1.2, lineCap: .round, dash: [4, 4])
            context.stroke(path, with: .color(Color.white.opacity(0.4)), style: dashedStyle)

            // Draw slice label (1 to 8)
            let text = Text("\(i)")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(Color.white.opacity(0.6))
            context.draw(text, at: CGPoint(x: x - (sliceWidth / 2.0), y: 10))
        }

        // Slice 8 label
        let text8 = Text("8")
            .font(.system(size: 9, weight: .bold, design: .monospaced))
            .foregroundColor(Color.white.opacity(0.6))
        context.draw(text8, at: CGPoint(x: size.width - (sliceWidth / 2.0), y: 10))
    }

    private func drawPlayhead(context: GraphicsContext, size: CGSize) {
        let currentProgress = isDragging ? dragPosition : track.playheadProgress
        let playheadX = CGFloat(currentProgress) * size.width

        // Vertical Playhead Line
        var linePath = Path()
        linePath.move(to: CGPoint(x: playheadX, y: 0))
        linePath.addLine(to: CGPoint(x: playheadX, y: size.height))

        context.stroke(
            linePath,
            with: .color(Color.white),
            lineWidth: 2.0
        )

        // Neon Glow around Playhead
        context.stroke(
            linePath,
            with: .color(track.displayColor.opacity(0.6)),
            lineWidth: 5.0
        )

        // Glowing indicator handles at top and bottom
        let topHandle = CGRect(x: playheadX - 4, y: 0, width: 8, height: 6)
        context.fill(Path(roundedRect: topHandle, cornerRadius: 2), with: .color(Color.white))

        let bottomHandle = CGRect(x: playheadX - 4, y: size.height - 6, width: 8, height: 6)
        context.fill(Path(roundedRect: bottomHandle, cornerRadius: 2), with: .color(Color.white))
    }
}
