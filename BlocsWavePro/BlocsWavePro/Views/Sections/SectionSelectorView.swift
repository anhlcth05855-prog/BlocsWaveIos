import SwiftUI

/// Section selector bar (A: Intro, B: Verse, C: Chorus, D: Outro) with glowing state indicator.
public struct SectionSelectorView: View {
    public let activeSectionID: SectionID
    public let onSectionSelected: (SectionID) -> Void

    public init(activeSectionID: SectionID, onSectionSelected: @escaping (SectionID) -> Void) {
        self.activeSectionID = activeSectionID
        self.onSectionSelected = onSectionSelected
    }

    public var body: some View {
        HStack(spacing: 6) {
            ForEach(SectionID.allCases, id: \.self) { section in
                let isActive = section == activeSectionID

                Button {
                    onSectionSelected(section)
                } label: {
                    HStack(spacing: 4) {
                        Text(section.rawValue)
                            .font(.system(size: 12, weight: .black, design: .monospaced))
                            .foregroundColor(isActive ? .black : .white)

                        Text(section.defaultName)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(isActive ? Color.black.opacity(0.8) : AppColors.textMuted)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(isActive ? section.accentColor : AppColors.surfaceCard)
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(isActive ? Color.white : Color.white.opacity(0.08), lineWidth: 1)
                    )
                    .shadow(color: isActive ? section.accentColor.opacity(0.5) : .clear, radius: 5)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
