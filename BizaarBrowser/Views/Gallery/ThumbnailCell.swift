import SwiftUI

struct ThumbnailCell: View {
    let file: MediaFile
    @State private var thumbnail: UIImage?
    @State private var isLoading = true

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack(alignment: .bottomLeading) {
                if let thumbnail = thumbnail {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .aspectRatio(1, contentMode: .fill)
                        .clipped()
                        .cornerRadius(10)
                } else if isLoading {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemGray5))
                        .aspectRatio(1, contentMode: .fill)
                        .overlay(
                            ProgressView()
                                .tint(.gold)
                        )
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemGray5))
                        .aspectRatio(1, contentMode: .fill)
                        .overlay(
                            Image(systemName: file.isVideo ? "film" : "photo")
                                .font(.title)
                                .foregroundColor(.gray)
                        )
                }

                HStack(spacing: 4) {
                    if let durationText = file.durationText {
                        Text(durationText)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(4)
                    }

                    Spacer()

                    if file.isVideo {
                        Image(systemName: "play.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.white)
                            .padding(4)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                }
                .padding(6)
            }

            HStack {
                Text(file.filename)
                    .font(.caption2)
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Spacer()

                Text(FileSizeFormatter.string(from: file.fileSize))
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            loadThumbnail()
        }
    }

    private func loadThumbnail() {
        let delay = Double.random(in: 0.05...0.3)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            DispatchQueue.global(qos: .userInitiated).async {
                let image = ThumbnailGenerator.generateThumbnail(for: file, size: CGSize(width: 250, height: 250))
                DispatchQueue.main.async {
                    self.thumbnail = image
                    self.isLoading = false
                }
            }
        }
    }
}
