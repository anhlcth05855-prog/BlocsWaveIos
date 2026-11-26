import SwiftUI

/// Compact live looper track row displaying track controls, mute/solo, and touchable waveform.
public struct TrackRowView: View {
    @Binding public var track: TrackModel
    public let onSeek: (Double) -> Void
    public let onMuteToggled: () -> Void
    public let onSoloToggled: () -> Void
    public let onSliceModeToggled: () -> Void
    public let onSliceSelected: (Int) -> Void
    public let onRecordTapped: () -> Void
    public let onInspectTapped: () -> Void
    public let onSoundBrowseTapped: () -> Void

    public var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 8) {
                // Track Control Column
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(track.displayColor)
                            .frame(width: 8, height: 8)
                            .shadow(color: track.displayColor, radius: 3)

                        Text(track.name)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)

                        if track.isUserRecorded {
                            Text("REC")
                                .font(.system(size: 8, weight: .black, design: .monospaced))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(AppColors.recordActive.opacity(0.3))
                                .foregroundColor(AppColors.recordActive)
                                .cornerRadius(3)
                        }
                    }

                    HStack(spacing: 4) {
                        // Mute Button
                        Button(action: onMuteToggled) {
                            Text("M")
                                .font(.system(size: 10, weight: .black, design: .monospaced))
                                .frame(width: 22, height: 22)
                                .foregroundColor(track.isMuted ? .white : AppColors.textSecondary)
                                .background(track.isMuted ? AppColors.muteRed : AppColors.surfaceCard)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(track.isMuted ? AppColors.muteRed : Color.white.opacity(0.1), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)

                        // Solo Button
                        Button(action: onSoloToggled) {
                            Text("S")
                                .font(.system(size: 10, weight: .black, design: .monospaced))
                                .frame(width: 22, height: 22)
                                .foregroundColor(track.isSolo ? .black : AppColors.textSecondary)
                                .background(track.isSolo ? AppColors.soloYellow : AppColors.surfaceCard)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(track.isSolo ? AppColors.soloYellow : Color.white.opacity(0.1), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)

                        // Slice Toggle Button
                        Button(action: onSliceModeToggled) {
                            Image(systemName: "scissors")
                                .font(.system(size: 10, weight: .bold))
                                .frame(width: 22, height: 22)
                                .foregroundColor(track.sliceState.isSliceModeEnabled ? .black : AppColors.textSecondary)
                                .background(track.sliceState.isSliceModeEnabled ? track.displayColor : AppColors.surfaceCard)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                        .buttonStyle(.plain)

                        // Record Button
                        Button(action: onRecordTapped) {
                            Image(systemName: "mic.fill")
                                .font(.system(size: 10, weight: .bold))
                                .frame(width: 22, height: 22)
                                .foregroundColor(track.isUserRecorded ? AppColors.recordActive : AppColors.textSecondary)
                                .background(AppColors.surfaceCard)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                        .buttonStyle(.plain)

                        // Sound Browser Button
                        Button(action: onSoundBrowseTapped) {
                            Image(systemName: "music.note.list")
                                .font(.system(size: 10, weight: .bold))
                                .frame(width: 22, height: 22)
                                .foregroundColor(AppColors.neonGold)
                                .background(AppColors.surfaceCard)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                        .buttonStyle(.plain)

                        // EQ / Inspector Button
                        Button(action: onInspectTapped) {
                            Image(systemName: "slider.vertical.3")
                                .font(.system(size: 10, weight: .bold))
                                .frame(width: 22, height: 22)
                                .foregroundColor(AppColors.neonCyan)
                                .background(AppColors.surfaceCard)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(width: 155)

                // Waveform Canvas Column
                TouchableWaveformCanvas(
                    track: track,
                    onSeek: onSeek,
                    onSliceTapped: onSliceSelected
                )
                .frame(height: 58)
            }

            // Slice Pads Row (appears when Slice Mode is active)
            if track.sliceState.isSliceModeEnabled {
                HStack(spacing: 8) {
                    Spacer().frame(width: 155)
                    SliceOverlayView(
                        track: track,
                        onSliceSelected: onSliceSelected
                    )
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(AppColors.surfaceDark)
                .opacity(track.isMuted ? 0.6 : 1.0)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(track.isSolo ? AppColors.soloYellow.opacity(0.8) : Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}
