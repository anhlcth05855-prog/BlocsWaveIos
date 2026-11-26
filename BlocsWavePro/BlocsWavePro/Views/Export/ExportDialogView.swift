import SwiftUI

/// Export dialog modal allowing choice between Master Mixdown and 8 Individual Stems.
public struct ExportDialogView: View {
    public let isExporting: Bool
    public let progressMessage: String
    public let onExportMixdown: () -> Void
    public let onExportStems: () -> Void

    @Environment(\.dismiss) private var dismiss

    public var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header card
                VStack(spacing: 8) {
                    Image(systemName: "waveform.badge.magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(AppColors.neonPurple)

                    Text("STUDIO AUDIO EXPORT")
                        .font(.system(size: 18, weight: .black, design: .monospaced))
                        .foregroundColor(.white)

                    Text("Render pristine uncompressed 44.1kHz 16-bit Stereo WAV audio files.")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 16)

                if isExporting {
                    VStack(spacing: 16) {
                        ProgressView()
                            .tint(AppColors.neonCyan)
                            .scaleEffect(1.4)

                        Text(progressMessage)
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                            .foregroundColor(AppColors.neonCyan)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 160)
                    .background(AppColors.surfaceCard)
                    .cornerRadius(14)
                    .padding(.horizontal)
                } else {
                    // Export Option 1: Master Mixdown
                    Button(action: onExportMixdown) {
                        HStack(spacing: 16) {
                            Image(systemName: "speaker.wave.3.fill")
                                .font(.system(size: 26))
                                .foregroundColor(AppColors.neonCyan)
                                .frame(width: 44)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("MASTER MIXDOWN")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)
                                Text("Full song bounce with all 8 tracks mixed, EQ'd and limited to 1 WAV file.")
                                    .font(.system(size: 11))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(AppColors.textMuted)
                        }
                        .padding()
                        .background(AppColors.surfaceCard)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.neonCyan.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)

                    // Export Option 2: Individual Stems
                    Button(action: onExportStems) {
                        HStack(spacing: 16) {
                            Image(systemName: "square.stack.3d.down.right.fill")
                                .font(.system(size: 26))
                                .foregroundColor(AppColors.neonGold)
                                .frame(width: 44)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("EXPORT ALL 8 STEMS")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)
                                Text("Separate WAV tracks for DAW production (Logic Pro, Ableton, FL Studio).")
                                    .font(.system(size: 11))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(AppColors.textMuted)
                        }
                        .padding()
                        .background(AppColors.surfaceCard)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.neonGold.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                }

                Spacer()
            }
            .padding(.vertical)
            .background(AppColors.backgroundDark.ignoresSafeArea())
            .navigationTitle("Export Audio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.textSecondary)
                }
            }
        }
    }
}
