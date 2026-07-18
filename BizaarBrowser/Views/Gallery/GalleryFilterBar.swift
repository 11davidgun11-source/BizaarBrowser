import SwiftUI

struct GalleryFilterBar: View {
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        VStack(spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(MediaType.allCases) { type in
                        FilterChip(
                            title: type.rawValue,
                            isSelected: settings.filterType == type,
                            action: { settings.filterType = type }
                        )
                    }
                }
                .padding(.horizontal)
            }

            HStack {
                Menu {
                    ForEach(SortOption.allCases) { option in
                        Button(option.rawValue) {
                            settings.sortOption = option
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.caption)
                        Text(settings.sortOption.rawValue)
                            .font(.caption)
                    }
                    .foregroundColor(.gold)
                }

                Spacer()
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(isSelected ? Color.gold : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}
