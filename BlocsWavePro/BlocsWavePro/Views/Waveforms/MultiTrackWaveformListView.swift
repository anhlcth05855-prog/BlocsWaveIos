import SwiftUI

/// Scrollable container rendering all 8 live looping tracks with waveforms and touch controls.
public struct MultiTrackWaveformListView: View {
    @Bindable public var viewModel: MainLooperViewModel

    public init(viewModel: MainLooperViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 6) {
                ForEach($viewModel.tracks) { $track in
                    TrackRowView(
                        track: $track,
                        playheadClock: viewModel.playheadClock,
                        onSeek: { progress in
                            viewModel.seekTrack(index: track.index, position: progress)
                        },
                        onMuteToggled: {
                            viewModel.toggleMute(for: track.index)
                        },
                        onSoloToggled: {
                            viewModel.toggleSolo(for: track.index)
                        },
                        onSliceModeToggled: {
                            viewModel.toggleSliceMode(for: track.index)
                        },
                        onSliceSelected: { sliceIndex in
                            viewModel.triggerSlice(for: track.index, sliceIndex: sliceIndex)
                        },
                        onRecordTapped: {
                            viewModel.openRecordingModal(for: track.index)
                        },
                        onInspectTapped: {
                            viewModel.selectedTrackIndex = track.index
                            viewModel.activeSheet = .eqInspector
                        },
                        onSoundBrowseTapped: {
                            viewModel.selectedTrackIndex = track.index
                            viewModel.activeSheet = .soundBrowser
                        }
                    )
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
        }
    }
}
