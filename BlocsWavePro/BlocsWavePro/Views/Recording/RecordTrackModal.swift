import SwiftUI

/// Modal for recording microphone input quantized to 1, 2, 4, or 8 musical bars.
public struct RecordTrackModal: View {
    public let trackIndex: Int
    public let masterBPM: Double
    public let micLevel: Float
    public let isRecording: Bool
    @Binding public var targetBars: Int
    public let onStartRecording: () -> Void
    public let onStopRecording: () -> Void

    @Environment(\.dismiss) private var dismiss

    public var body: some View {
        NavigationStack {
            VStack(spacing: 28) {
                // Info header
                VStack(spacing: 8) {
                    Image(systemName: "mic.circle.fill")
                        .font(.system(size: 54))
                        .foregroundColor(isRecording ? AppColors.recordActive : AppColors.neonCyan)
                        .scaleEffect(isRecording ? 1.12 : 1.0)
                        .animation(isRecording ? .easeInOut(duration: 0.8).repeatForever(autoreverses: true) : .default, value: isRecording)

                    Text(isRecording ? "RECORDING LOOP..." : "RECORD LIVE VOCAL / INSTRUMENT")
                        .font(.system(size: 16, weight: .black, design: .monospaced))
                        .foregroundColor(.white)

                    Text("Quantized to master tempo: \(Int(masterBPM)) BPM")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.top, 16)

                // Input VU Meter
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("MICROPHONE INPUT LEVEL")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(AppColors.textMuted)
                        Spacer()
                        Text("\(Int(micLevel * 100))%")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }

                    InputLevelMeterView(level: micLevel)
                }
                .padding()
                .background(AppColors.surfaceCard)
                .cornerRadius(12)
                .padding(.horizontal)

                // Bar Quantization Selector (1, 2, 4, 8 Bars)
                VStack(alignment: .leading, spacing: 10) {
                    Text("LOOP LENGTH (QUANTIZED BARS)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(AppColors.textMuted)

                    HStack(spacing: 12) {
                        ForEach([1, 2, 4, 8], id: \.self) { bars in
                            let isSelected = targetBars == bars
                            Button {
                                targetBars = bars
                            } label: {
                                VStack(spacing: 2) {
                                    Text("\(bars)")
                                        .font(.system(size: 20, weight: .black))
                                        .foregroundColor(isSelected ? .black : .white)
                                    Text(bars == 1 ? "BAR" : "BARS")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(isSelected ? Color.black.opacity(0.8) : AppColors.textMuted)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(isSelected ? AppColors.neonCyan : AppColors.surfaceCard)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(isSelected ? Color.white : Color.white.opacity(0.1), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                            .disabled(isRecording)
                        }
                    }
                }
                .padding(.horizontal)

                Spacer()

                // Big Record / Stop Trigger Button
                Button {
                    if isRecording {
                        onStopRecording()
                    } else {
                        onStartRecording()
                    }
                } label: {
                    HStack(spacing: 10) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 14, height: 14)
                        Text(isRecording ? "STOP RECORDING" : "START RECORDING")
                            .font(.system(size: 16, weight: .black, design: .monospaced))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(isRecording ? AppColors.recordActive : AppColors.electricBlue)
                    .cornerRadius(14)
                    .shadow(color: (isRecording ? AppColors.recordActive : AppColors.electricBlue).opacity(0.6), radius: 10)
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .background(AppColors.backgroundDark.ignoresSafeArea())
            .navigationTitle("Record Track \(trackIndex + 1)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if isRecording {
                            onStopRecording()
                        }
                        dismiss()
                    }
                    .foregroundColor(AppColors.textSecondary)
                }
            }
        }
    }
}
