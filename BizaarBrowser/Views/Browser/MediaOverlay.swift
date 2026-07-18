import SwiftUI

struct MediaOverlay: View {
    let media: [DetectedMedia]
    let onDownload: (DetectedMedia) -> Void
    let onDismiss: () -> Void

    @State private var downloadedIDs: Set<UUID> = []

    var body: some View {
        VStack(spacing: 0) {
            Divider()

            HStack {
                Text("\(media.count) media file\(media.count == 1 ? "" : "s") detected")
                    .font(.subheadline.bold())
                    .foregroundColor(.primary)

                Spacer()

                Button("Download All") {
                    for item in media {
                        onDownload(item)
                        downloadedIDs.insert(item.id)
                    }
                }
                .font(.subheadline.bold())
                .foregroundColor(.gold)

                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .padding(.leading, 8)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 10) {
                    ForEach(media) { item in
                        MediaThumbnailCard(
                            media: item,
                            isDownloaded: downloadedIDs.contains(item.id),
                            onDownload: {
                                onDownload(item)
                                downloadedIDs.insert(item.id)
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
        }
        .background(.ultraThinMaterial)
    }
}

struct MediaThumbnailCard: View {
    let media: DetectedMedia
    let isDownloaded: Bool
    let onDownload: () -> Void

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray5))
                    .frame(width: 80, height: 80)

                Image(systemName: mediaIcon)
                    .font(.title2)
                    .foregroundColor(.gold)
            }

            Text(media.displayName)
                .font(.caption2)
                .lineLimit(1)
                .frame(width: 80)

            Button(action: onDownload) {
                Image(systemName: isDownloaded ? "checkmark.circle.fill" : "arrow.down.circle.fill")
                    .foregroundColor(isDownloaded ? .green : .gold)
                    .font(.title3)
            }
            .disabled(isDownloaded)
        }
        .frame(width: 80)
    }

    private var mediaIcon: String {
        switch media.mediaType {
        case .image: return "photo"
        case .video: return "play.rectangle.fill"
        case .gif: return "livephoto"
        case .all: return "questionmark"
        }
    }
}
