import SwiftUI

/// Animated Tap Tempo trigger button with visual haptic feedback.
public struct TapTempoButton: View {
    public let onTap: () -> Void

    @State private var isPulsing: Bool = false

    public init(onTap: @escaping () -> Void) {
        self.onTap = onTap
    }

    public var body: some View {
        Button {
            onTap()
            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                isPulsing = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                isPulsing = false
            }
        } label: {
            VStack(spacing: 2) {
                Text("TAP")
                    .font(.system(size: 11, weight: .black, design: .monospaced))
                    .foregroundColor(AppColors.neonCyan)
                Text("TEMPO")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(AppColors.textMuted)
            }
            .frame(width: 54, height: 38)
            .background(AppColors.surfaceCard)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isPulsing ? AppColors.neonCyan : Color.white.opacity(0.12), lineWidth: isPulsing ? 2 : 1)
            )
            .scaleEffect(isPulsing ? 1.08 : 1.0)
            .shadow(color: isPulsing ? AppColors.neonCyan.opacity(0.6) : .clear, radius: 6)
        }
        .buttonStyle(.plain)
    }
}
