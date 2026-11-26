import SwiftUI

/// Animated live VU meter for microphone input level.
public struct InputLevelMeterView: View {
    public let level: Float // 0.0 to 1.0

    public init(level: Float) {
        self.level = level
    }

    public var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let fillWidth = max(0, min(width, width * CGFloat(level)))

            ZStack(alignment: .leading) {
                // Background bar
                RoundedRectangle(cornerRadius: 4)
                    .fill(AppColors.surfaceCard)

                // Level fill bar with gradient (Green -> Yellow -> Red)
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [
                                AppColors.playActive,
                                AppColors.neonGold,
                                AppColors.recordActive
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: fillWidth)
                    .animation(.linear(duration: 0.06), value: level)
            }
        }
        .frame(height: 12)
    }
}
