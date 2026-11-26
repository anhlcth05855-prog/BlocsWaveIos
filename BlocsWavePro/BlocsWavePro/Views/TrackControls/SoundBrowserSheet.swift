import SwiftUI

/// Sheet modal enabling users to audition, browse, and swap instruments and loops from 5 sound packs.
public struct SoundBrowserSheet: View {
    public let trackIndex: Int
    public let trackType: TrackType
    public let currentPresetName: String
    public let onSelectPreset: (SoundPreset) -> Void
    public let onAuditionPreset: (SoundPreset) -> Void
    public let onStopAudition: () -> Void

    @State private var selectedGenreFilter: SoundGenre? = nil
    @State private var auditioningPresetId: String? = nil
    @Environment(\.dismiss) private var dismiss

    public init(
        trackIndex: Int,
        trackType: TrackType,
        currentPresetName: String,
        onSelectPreset: @escaping (SoundPreset) -> Void,
        onAuditionPreset: @escaping (SoundPreset) -> Void,
        onStopAudition: @escaping () -> Void
    ) {
        self.trackIndex = trackIndex
        self.trackType = trackType
        self.currentPresetName = currentPresetName
        self.onSelectPreset = onSelectPreset
        self.onAuditionPreset = onAuditionPreset
        self.onStopAudition = onStopAudition
    }

    private var filteredPresets: [SoundPreset] {
        let presetsForType = SoundLibrary.presets(for: trackType)
        if let genre = selectedGenreFilter {
            return presetsForType.filter { $0.genre == genre }
        }
        return presetsForType
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Header track summary card
                HStack(spacing: 12) {
                    Image(systemName: trackType.systemIconName)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(AppColors.neonCyan)
                        .frame(width: 50, height: 50)
                        .background(AppColors.neonCyan.opacity(0.15))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 3) {
                        Text("TRACK \(trackIndex + 1): \(trackType.rawValue.uppercased())")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(AppColors.neonCyan)

                        Text("Currently Loaded: \(currentPresetName)")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                    }

                    Spacer()
                }
                .padding()
                .background(AppColors.surfaceCard)
                .cornerRadius(12)
                .padding(.horizontal)

                // Genre Filter Pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        Button {
                            selectedGenreFilter = nil
                        } label: {
                            Text("All Genres")
                                .font(.system(size: 12, weight: .bold))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(selectedGenreFilter == nil ? AppColors.neonCyan : AppColors.surfaceCard)
                                .foregroundColor(selectedGenreFilter == nil ? .black : AppColors.textSecondary)
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)

                        ForEach(SoundGenre.allCases) { genre in
                            let isSelected = selectedGenreFilter == genre
                            Button {
                                selectedGenreFilter = genre
                            } label: {
                                HStack(spacing: 6) {
                                    Text(genre.icon)
                                    Text(genre.rawValue)
                                        .font(.system(size: 12, weight: .bold))
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(isSelected ? genre.accentColor : AppColors.surfaceCard)
                                .foregroundColor(isSelected ? .black : AppColors.textSecondary)
                                .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }

                // Presets List
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(filteredPresets) { preset in
                            presetCard(preset)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                }
            }
            .padding(.top, 8)
            .background(AppColors.backgroundDark.ignoresSafeArea())
            .navigationTitle("Sound Browser")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        onStopAudition()
                        dismiss()
                    }
                    .foregroundColor(AppColors.neonCyan)
                }
            }
        }
    }

    private func presetCard(_ preset: SoundPreset) -> some View {
        let isAuditioning = auditioningPresetId == preset.id
        let isCurrent = currentPresetName == preset.name

        return HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(preset.genre.icon)
                    Text(preset.name)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)

                    Text(preset.genre.rawValue)
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(preset.genre.accentColor.opacity(0.2))
                        .foregroundColor(preset.genre.accentColor)
                        .cornerRadius(4)
                }

                Text(preset.description)
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(2)
            }

            Spacer()

            // Action Buttons: Audition & Load
            HStack(spacing: 8) {
                // Audition button
                Button {
                    if isAuditioning {
                        onStopAudition()
                        auditioningPresetId = nil
                    } else {
                        auditioningPresetId = preset.id
                        onAuditionPreset(preset)
                    }
                } label: {
                    Image(systemName: isAuditioning ? "stop.fill" : "play.fill")
                        .font(.system(size: 12, weight: .bold))
                        .frame(width: 34, height: 34)
                        .foregroundColor(isAuditioning ? .black : AppColors.neonGold)
                        .background(isAuditioning ? AppColors.neonGold : AppColors.surfaceDark)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(AppColors.neonGold.opacity(0.4), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)

                // Load button
                Button {
                    onStopAudition()
                    onSelectPreset(preset)
                    dismiss()
                } label: {
                    Text(isCurrent ? "ACTIVE" : "LOAD")
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .padding(.horizontal, 10)
                        .frame(height: 34)
                        .background(isCurrent ? AppColors.playActive.opacity(0.25) : AppColors.neonCyan)
                        .foregroundColor(isCurrent ? AppColors.playActive : .black)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(AppColors.surfaceCard)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isCurrent ? AppColors.neonCyan : Color.white.opacity(0.06), lineWidth: isCurrent ? 1.5 : 1)
        )
    }
}
