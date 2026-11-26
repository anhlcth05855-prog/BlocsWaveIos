import SwiftUI

/// Sheet modal to select Master Musical Key and Major/Minor mode with automatic harmonization preview.
public struct MasterKeyPickerSheet: View {
    @Binding public var currentKey: MusicalKey
    public let onKeySelected: (MusicalKey) -> Void

    @Environment(\.dismiss) private var dismiss

    public var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Current Key Card
                VStack(spacing: 8) {
                    Text("HARMONIC MASTER KEY")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(AppColors.textMuted)

                    Text(currentKey.fullDisplayName)
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(AppColors.neonGold)
                        .shadow(color: AppColors.neonGold.opacity(0.5), radius: 8)

                    Text("All tracks will pitch-shift in real-time to match this harmonic scale.")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(AppColors.surfaceCard)
                .cornerRadius(12)
                .padding(.horizontal)

                // Scale Mode Picker (Major vs Minor)
                Picker("Scale Mode", selection: $currentKey.mode) {
                    ForEach(ScaleMode.allCases, id: \.self) { mode in
                        Text(mode.fullName).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .onChange(of: currentKey.mode) { _, newMode in
                    currentKey.mode = newMode
                    onKeySelected(currentKey)
                }

                // 12 Chromatic Pitch Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
                    ForEach(PitchClass.allCases, id: \.self) { pitch in
                        let isSelected = currentKey.pitch == pitch

                        Button {
                            currentKey.pitch = pitch
                            onKeySelected(currentKey)
                        } label: {
                            VStack(spacing: 2) {
                                Text(pitch.name)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(isSelected ? .black : .white)

                                if !pitch.flatName.isEmpty && pitch.flatName != pitch.name {
                                    Text(pitch.flatName)
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(isSelected ? Color.black.opacity(0.8) : AppColors.textMuted)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(isSelected ? AppColors.neonGold : AppColors.surfaceCard)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(isSelected ? Color.white : Color.white.opacity(0.1), lineWidth: 1)
                            )
                            .shadow(color: isSelected ? AppColors.neonGold.opacity(0.6) : .clear, radius: 6)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.vertical)
            .background(AppColors.backgroundDark.ignoresSafeArea())
            .navigationTitle("Master Harmonization")
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
}
