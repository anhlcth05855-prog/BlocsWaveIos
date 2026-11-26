import SwiftUI

/// Detailed mixer channel inspector for adjusting EQ, Pan, Volume, and Slice modes.
public struct TrackDetailSheet: View {
    @Binding public var track: TrackModel
    public let onVolumeChanged: (Float) -> Void
    public let onPanChanged: (Float) -> Void
    public let onEQChanged: (EQSettings) -> Void
    public let onSliceModeToggled: () -> Void
    public let onSliceSelected: (Int) -> Void

    @Environment(\.dismiss) private var dismiss

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Track Title & Badges
                    HStack(spacing: 12) {
                        Image(systemName: track.type.systemIconName)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(track.displayColor)
                            .frame(width: 48, height: 48)
                            .background(track.displayColor.opacity(0.15))
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 4) {
                            Text(track.name)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)

                            HStack(spacing: 8) {
                                Text(track.bpmDisplay)
                                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(AppColors.surfaceCard)
                                    .cornerRadius(4)
                                    .foregroundColor(AppColors.textSecondary)

                                Text(track.originalKey.displayName)
                                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(AppColors.surfaceCard)
                                    .cornerRadius(4)
                                    .foregroundColor(track.displayColor)
                            }
                        }

                        Spacer()
                    }
                    .padding(.horizontal)

                    // Volume & Pan Controls Card
                    VStack(spacing: 18) {
                        // Volume Fader
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("VOLUME")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(AppColors.textSecondary)
                                Spacer()
                                Text("\(Int(track.volume * 100))%")
                                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white)
                            }

                            Slider(
                                value: Binding(
                                    get: { Double(track.volume) },
                                    set: {
                                        track.volume = Float($0)
                                        onVolumeChanged(Float($0))
                                    }
                                ),
                                in: 0.0...1.0
                            )
                            .tint(track.displayColor)
                        }

                        // Stereo Pan Slider
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("STEREO PAN")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(AppColors.textSecondary)
                                Spacer()
                                Text(panLabel(track.pan))
                                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white)
                            }

                            Slider(
                                value: Binding(
                                    get: { Double(track.pan) },
                                    set: {
                                        track.pan = Float($0)
                                        onPanChanged(Float($0))
                                    }
                                ),
                                in: -1.0...1.0
                            )
                            .tint(track.displayColor)

                            HStack {
                                Text("L").font(.caption2).foregroundColor(AppColors.textMuted)
                                Spacer()
                                Text("CENTER").font(.caption2).foregroundColor(AppColors.textMuted)
                                Spacer()
                                Text("R").font(.caption2).foregroundColor(AppColors.textMuted)
                            }
                        }
                    }
                    .padding()
                    .background(AppColors.surfaceCard)
                    .cornerRadius(14)
                    .padding(.horizontal)

                    // 3-Band Parametric EQ Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("3-BAND PARAMETRIC EQ")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppColors.textSecondary)
                            .padding(.horizontal)

                        ParametricEQView(
                            eq: $track.eqSettings,
                            trackColor: track.displayColor,
                            onEQChanged: onEQChanged
                        )
                        .padding(.horizontal)
                    }

                    // Slice Mode Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("SLICE MODE")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AppColors.textSecondary)
                            Spacer()
                            Toggle("", isOn: Binding(
                                get: { track.sliceState.isSliceModeEnabled },
                                set: { _ in onSliceModeToggled() }
                            ))
                            .tint(track.displayColor)
                            .labelsHidden()
                        }

                        if track.sliceState.isSliceModeEnabled {
                            Text("Tap any slice below to loop exclusively inside that section:")
                                .font(.system(size: 11))
                                .foregroundColor(AppColors.textMuted)

                            SliceOverlayView(
                                track: track,
                                onSliceSelected: onSliceSelected
                            )
                        }
                    }
                    .padding()
                    .background(AppColors.surfaceCard)
                    .cornerRadius(14)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(AppColors.backgroundDark.ignoresSafeArea())
            .navigationTitle("Track Inspector")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.neonCyan)
                }
            }
        }
    }

    private func panLabel(_ pan: Float) -> String {
        if abs(pan) < 0.05 {
            return "Center"
        } else if pan < 0 {
            return "L \(Int(abs(pan) * 100))"
        } else {
            return "R \(Int(pan * 100))"
        }
    }
}
