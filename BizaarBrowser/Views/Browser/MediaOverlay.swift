import SwiftUI

struct MediaSheetView: View {
    let media: [DetectedMedia]
    let onDownload: (DetectedMedia) -> Void
    let onDownloadAll: () -> Void

    @State private var downloadedIDs: Set<UUID> = []

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Text("\(media.count) media file\(media.count == 1 ? "" : "s") detected")
                        .font(.subheadline.bold())
                        .foregroundColor(.primary)

                    Spacer()

                    Button("Download All") {
                        onDownloadAll()
                        for item in media {
                            downloadedIDs.insert(item.id)
                        }
                    }
                    .font(.subheadline.bold())
                    .foregroundColor(.gold)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                Divider()

                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 80, maximum: 120), spacing: 10)
                    ], spacing: 10) {
                        ForEach(media) { item in
                            MediaGridCard(
                                media: item,
                                isDownloaded: downloadedIDs.contains(item.id),
                                onDownload: {
                                    onDownload(item)
                                    downloadedIDs.insert(item.id)
                                }
                            )
                        }
                    }
                    .padding(12)
                }
            }
            .navigationTitle("Detected Media")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct MediaGridCard: View {
    let media: DetectedMedia
    let isDownloaded: Bool
    let onDownload: () -> Void

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray5))
                    .aspectRatio(1, contentMode: .fit)

                Image(systemName: mediaIcon)
                    .font(.title2)
                    .foregroundColor(.gold)
            }

            Text(media.displayName)
                .font(.caption2)
                .lineLimit(1)

            Button(action: onDownload) {
                Image(systemName: isDownloaded ? "checkmark.circle.fill" : "arrow.down.circle.fill")
                    .foregroundColor(isDownloaded ? .green : .gold)
                    .font(.title3)
            }
            .disabled(isDownloaded)
        }
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
