import SwiftUI

/// 3-Band Parametric EQ visualizer & editor: Low Shelf (120Hz), Mid (1kHz), High Shelf (7kHz).
public struct ParametricEQView: View {
    @Binding public var eq: EQSettings
    public let trackColor: Color
    public let onEQChanged: (EQSettings) -> Void

    public init(
        eq: Binding<EQSettings>,
        trackColor: Color,
        onEQChanged: @escaping (EQSettings) -> Void
    ) {
        self._eq = eq
        self.trackColor = trackColor
        self.onEQChanged = onEQChanged
    }

    public var body: some View {
        VStack(spacing: 16) {
            // Visual Frequency Curve
            Canvas { context, size in
                drawEQCurve(context: context, size: size)
            }
            .frame(height: 110)
            .background(AppColors.surfaceDark)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(AppColors.surfaceCardBorder, lineWidth: 1)
            )

            // 3 Band Sliders
            HStack(spacing: 20) {
                eqBandColumn(
                    title: "LOW",
                    freq: "120 Hz",
                    gain: Binding(
                        get: { Double(eq.lowGainDB) },
                        set: {
                            eq.lowGainDB = Float($0)
                            onEQChanged(eq)
                        }
                    )
                )

                eqBandColumn(
                    title: "MID",
                    freq: "1.0 kHz",
                    gain: Binding(
                        get: { Double(eq.midGainDB) },
                        set: {
                            eq.midGainDB = Float($0)
                            onEQChanged(eq)
                        }
                    )
                )

                eqBandColumn(
                    title: "HIGH",
                    freq: "7.0 kHz",
                    gain: Binding(
                        get: { Double(eq.highGainDB) },
                        set: {
                            eq.highGainDB = Float($0)
                            onEQChanged(eq)
                        }
                    )
                )
            }
            .padding(.vertical, 8)

            // Reset Flat button
            Button {
                eq = .flat
                onEQChanged(eq)
            } label: {
                Text("RESET TO FLAT (0 dB)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(AppColors.surfaceCard)
                    .cornerRadius(6)
            }
        }
        .padding()
        .background(AppColors.surfaceDark)
        .cornerRadius(14)
    }

    private func eqBandColumn(title: String, freq: String, gain: Binding<Double>) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 11, weight: .black))
                .foregroundColor(trackColor)

            Text(freq)
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundColor(AppColors.textMuted)

            Text(String(format: "%+.1f dB", gain.wrappedValue))
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(.white)

            Slider(value: gain, in: -12.0...12.0, step: 0.5)
                .tint(trackColor)
        }
    }

    // MARK: - EQ Curve Drawing

    private func drawEQCurve(context: GraphicsContext, size: CGSize) {
        let width = size.width
        let height = size.height
        let midY = height / 2.0

        // Grid lines (0 dB, +6dB, -6dB)
        var zeroGrid = Path()
        zeroGrid.move(to: CGPoint(x: 0, y: midY))
        zeroGrid.addLine(to: CGPoint(x: width, y: midY))
        context.stroke(zeroGrid, with: .color(Color.white.opacity(0.15)), lineWidth: 1)

        let pointsCount = 60
        var curvePath = Path()
        var fillPath = Path()

        fillPath.move(to: CGPoint(x: 0, y: midY))

        for i in 0...pointsCount {
            let normX = Double(i) / Double(pointsCount)
            let x = CGFloat(normX) * width

            // Approximating 3-band response curve
            // Low shelf response (< 0.3 x)
            let lowInfluence = 1.0 / (1.0 + exp((normX - 0.25) * 15.0))
            // Mid peaking bell response (centered around 0.5 x)
            let midDiff = (normX - 0.5) * 3.5
            let midInfluence = exp(-midDiff * midDiff)
            // High shelf response (> 0.7 x)
            let highInfluence = 1.0 / (1.0 + exp(-(normX - 0.75) * 15.0))

            let totalDB = Double(eq.lowGainDB) * lowInfluence +
                          Double(eq.midGainDB) * midInfluence +
                          Double(eq.highGainDB) * highInfluence

            // Map -14dB...+14dB to height
            let yOffset = CGFloat(totalDB / 14.0) * (height * 0.4)
            let y = midY - yOffset

            if i == 0 {
                curvePath.move(to: CGPoint(x: x, y: y))
                fillPath.addLine(to: CGPoint(x: x, y: y))
            } else {
                curvePath.addLine(to: CGPoint(x: x, y: y))
                fillPath.addLine(to: CGPoint(x: x, y: y))
            }
        }

        fillPath.addLine(to: CGPoint(x: width, y: midY))
        fillPath.closeSubpath()

        // Glow fill
        context.fill(fillPath, with: .color(trackColor.opacity(0.18)))

        // Stroke line
        context.stroke(curvePath, with: .color(trackColor), lineWidth: 2.5)
    }
}
