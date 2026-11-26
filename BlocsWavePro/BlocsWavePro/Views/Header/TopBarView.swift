import SwiftUI

/// Primary navigation and master transport header bar.
public struct TopBarView: View {
    @Binding public var project: ProjectState
    @Binding public var selectedGenre: SoundGenre
    public let onTogglePlayback: () -> Void
    public let onBPMIncrement: (Double) -> Void
    public let onTapTempo: () -> Void
    public let onKeyTapped: () -> Void
    public let onMetronomeToggled: () -> Void
    public let onGenreSelected: (SoundGenre) -> Void
    public let onSectionSelected: (SectionID) -> Void
    public let onExportTapped: () -> Void

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // Master Play / Stop Button
                    Button(action: onTogglePlayback) {
                        HStack(spacing: 5) {
                            Image(systemName: project.isPlaying ? "stop.fill" : "play.fill")
                                .font(.system(size: 14, weight: .bold))
                            Text(project.isPlaying ? "STOP" : "PLAY")
                                .font(.system(size: 12, weight: .black, design: .monospaced))
                        }
                        .foregroundColor(project.isPlaying ? .black : .white)
                        .frame(width: 76, height: 36)
                        .background(project.isPlaying ? AppColors.playActive : AppColors.surfaceCard)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(project.isPlaying ? AppColors.playActive : Color.white.opacity(0.15), lineWidth: 1)
                        )
                        .shadow(color: project.isPlaying ? AppColors.playActive.opacity(0.6) : .clear, radius: 8)
                    }
                    .buttonStyle(.plain)

                    // Master BPM Display & Stepper
                    HStack(spacing: 2) {
                        Button {
                            onBPMIncrement(-1.0)
                        } label: {
                            Image(systemName: "minus")
                                .font(.system(size: 11, weight: .bold))
                                .frame(width: 22, height: 36)
                                .foregroundColor(AppColors.textSecondary)
                        }

                        VStack(spacing: 1) {
                            Text("\(Int(project.masterBPM))")
                                .font(.system(size: 14, weight: .black, design: .monospaced))
                                .foregroundColor(.white)
                            Text("BPM")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(AppColors.textMuted)
                        }
                        .frame(width: 40)

                        Button {
                            onBPMIncrement(1.0)
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 11, weight: .bold))
                                .frame(width: 22, height: 36)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                    .background(AppColors.surfaceCard)
                    .cornerRadius(8)

                    // Tap Tempo Button
                    TapTempoButton(onTap: onTapTempo)

                    // Master Key Selector
                    Button(action: onKeyTapped) {
                        VStack(spacing: 1) {
                            Text(project.masterKey.displayName)
                                .font(.system(size: 13, weight: .black, design: .monospaced))
                                .foregroundColor(AppColors.neonGold)
                            Text("KEY")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(AppColors.textMuted)
                        }
                        .frame(width: 52, height: 36)
                        .background(AppColors.surfaceCard)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(AppColors.neonGold.opacity(0.4), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)

                    // Metronome Toggle Button
                    Button(action: onMetronomeToggled) {
                        Image(systemName: "metronome")
                            .font(.system(size: 14, weight: .bold))
                            .frame(width: 36, height: 36)
                            .foregroundColor(project.isMetronomeEnabled ? .black : AppColors.textSecondary)
                            .background(project.isMetronomeEnabled ? AppColors.metronomeTick : AppColors.surfaceCard)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(project.isMetronomeEnabled ? AppColors.metronomeTick : Color.white.opacity(0.1), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)

                    // Export Button
                    Button(action: onExportTapped) {
                        HStack(spacing: 4) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 12, weight: .bold))
                            Text("EXPORT")
                                .font(.system(size: 11, weight: .black, design: .monospaced))
                        }
                        .foregroundColor(.white)
                        .frame(height: 36)
                        .padding(.horizontal, 10)
                        .background(AppColors.neonPurple.opacity(0.85))
                        .cornerRadius(8)
                        .shadow(color: AppColors.neonPurple.opacity(0.5), radius: 6)
                    }
                    .buttonStyle(.plain)
                }
            }

            // Sound Packs / Genre Selector Bar
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    Text("PACKS")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(AppColors.textMuted)

                    ForEach(SoundGenre.allCases) { genre in
                        let isSelected = selectedGenre == genre
                        Button {
                            selectedGenre = genre
                            onGenreSelected(genre)
                        } label: {
                            HStack(spacing: 3) {
                                Text(genre.icon)
                                    .font(.system(size: 10))
                                Text(genre.rawValue)
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(isSelected ? .black : .white)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(isSelected ? genre.accentColor : AppColors.surfaceCard)
                            .cornerRadius(5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(isSelected ? Color.white : Color.white.opacity(0.08), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // Song Sections Bar (A, B, C, D)
            HStack {
                Text("SECTIONS")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(AppColors.textMuted)

                SectionSelectorView(
                    activeSectionID: project.activeSectionID,
                    onSectionSelected: onSectionSelected
                )

                Spacer()
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(AppColors.surfaceDark)
    }
}
