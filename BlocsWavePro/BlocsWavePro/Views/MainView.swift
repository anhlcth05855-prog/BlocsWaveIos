import SwiftUI

/// Root SwiftUI View for Blocs Wave Pro live music looping and recording.
public struct MainView: View {
    @State private var viewModel = MainLooperViewModel()

    public init() {}

    public var body: some View {
        ZStack {
            // Ambient Dark Background with subtle neon gradient
            AppGradients.backgroundMesh
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Master Header Navigation & Transport Bar
                TopBarView(
                    project: $viewModel.project,
                    selectedGenre: $viewModel.selectedGenre,
                    onTogglePlayback: {
                        viewModel.togglePlayback()
                    },
                    onBPMIncrement: { delta in
                        viewModel.incrementBPM(by: delta)
                    },
                    onTapTempo: {
                        viewModel.handleTapTempo()
                    },
                    onKeyTapped: {
                        viewModel.isKeyPickerPresented = true
                    },
                    onMetronomeToggled: {
                        viewModel.toggleMetronome()
                    },
                    onGenreSelected: { genre in
                        viewModel.applyGenrePack(genre)
                    },
                    onSectionSelected: { sectionID in
                        viewModel.switchSection(to: sectionID)
                    },
                    onExportTapped: {
                        viewModel.isExportDialogPresented = true
                    }
                )

                Divider()
                    .background(Color.white.opacity(0.1))

                // 8-Track Multi-Waveform Area
                MultiTrackWaveformListView(viewModel: viewModel)

                // Master Bottom Quick Controls
                bottomStatusBar
            }
        }
        .preferredColorScheme(.dark)
        // Sheets & Modals
        .sheet(isPresented: $viewModel.isKeyPickerPresented) {
            MasterKeyPickerSheet(
                currentKey: $viewModel.project.masterKey,
                onKeySelected: { newKey in
                    viewModel.setMasterKey(newKey)
                }
            )
        }
        .sheet(isPresented: $viewModel.isEQSheetPresented) {
            if viewModel.selectedTrackIndex < viewModel.tracks.count {
                TrackDetailSheet(
                    track: $viewModel.tracks[viewModel.selectedTrackIndex],
                    onVolumeChanged: { vol in
                        viewModel.setVolume(for: viewModel.selectedTrackIndex, volume: vol)
                    },
                    onPanChanged: { pan in
                        viewModel.setPan(for: viewModel.selectedTrackIndex, pan: pan)
                    },
                    onEQChanged: { eq in
                        viewModel.updateEQ(for: viewModel.selectedTrackIndex, eq: eq)
                    },
                    onSliceModeToggled: {
                        viewModel.toggleSliceMode(for: viewModel.selectedTrackIndex)
                    },
                    onSliceSelected: { sliceIdx in
                        viewModel.triggerSlice(for: viewModel.selectedTrackIndex, sliceIndex: sliceIdx)
                    }
                )
            }
        }
        .sheet(isPresented: $viewModel.isRecordingModalPresented) {
            RecordTrackModal(
                trackIndex: viewModel.selectedTrackIndex,
                masterBPM: viewModel.project.masterBPM,
                micLevel: viewModel.liveMicLevel,
                isRecording: viewModel.isLiveRecording,
                targetBars: $viewModel.recordingBarsCount,
                onStartRecording: {
                    viewModel.startLiveRecording()
                },
                onStopRecording: {
                    viewModel.stopLiveRecording()
                }
            )
        }
        .sheet(isPresented: $viewModel.isExportDialogPresented) {
            ExportDialogView(
                isExporting: viewModel.isExporting,
                progressMessage: viewModel.exportProgressMessage,
                onExportMixdown: {
                    viewModel.exportMasterMixdown()
                },
                onExportStems: {
                    viewModel.exportAllStems()
                }
            )
        }
        .sheet(isPresented: $viewModel.isShareSheetPresented) {
            ShareSheet(activityItems: viewModel.exportedFileURLs)
        }
        .sheet(isPresented: $viewModel.isSoundBrowserPresented) {
            if viewModel.selectedTrackIndex < viewModel.tracks.count {
                let track = viewModel.tracks[viewModel.selectedTrackIndex]
                SoundBrowserSheet(
                    trackIndex: viewModel.selectedTrackIndex,
                    trackType: track.type,
                    currentPresetName: track.name,
                    onSelectPreset: { preset in
                        viewModel.loadPreset(for: viewModel.selectedTrackIndex, preset: preset)
                    },
                    onAuditionPreset: { preset in
                        viewModel.auditionPreset(preset)
                    },
                    onStopAudition: {
                        viewModel.stopAudition()
                    }
                )
            }
        }
    }

    // MARK: - Bottom Status & Global Helpers

    private var bottomStatusBar: some View {
        HStack(spacing: 16) {
            HStack(spacing: 6) {
                Circle()
                    .fill(viewModel.project.isPlaying ? AppColors.playActive : AppColors.textMuted)
                    .frame(width: 8, height: 8)
                Text(viewModel.project.isPlaying ? "LIVE LOOPING ACTIVE" : "ENGINE STANDBY")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(AppColors.textSecondary)
            }

            Spacer()

            // Restart to Loop Beginning
            Button {
                viewModel.seekAll(to: 0.0)
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "backward.end.fill")
                        .font(.system(size: 10))
                    Text("LOOP START")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                }
                .foregroundColor(AppColors.textSecondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(AppColors.surfaceCard)
                .cornerRadius(4)
            }
            .buttonStyle(.plain)

            // Current Master Key info
            HStack(spacing: 4) {
                Image(systemName: "tuningfork")
                    .font(.system(size: 10))
                    .foregroundColor(AppColors.neonGold)
                Text("KEY: \(viewModel.project.masterKey.displayName)")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(AppColors.neonGold)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(AppColors.surfaceDark)
    }
}
