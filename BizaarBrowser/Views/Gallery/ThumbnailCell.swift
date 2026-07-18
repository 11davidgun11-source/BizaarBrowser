import SwiftUI

struct ThumbnailCell: View {
    let file: MediaFile
    @State private var thumbnail: UIImage?

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if let thumbnail = thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .clipped()
                    .cornerRadius(8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray5))
                    .aspectRatio(1, contentMode: .fill)
                    .overlay(
                        ProgressView()
                            .tint(.gold)
                    )
            }

            if file.isVideo {
                Image(systemName: "play.fill")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(4)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Circle())
                    .padding(6)
            }

            if file.isAnimated && !file.isVideo {
                Text("GIF")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.gold)
                    .cornerRadius(4)
                    .padding(6)
            }
        }
        .onAppear {
            loadThumbnail()
        }
    }

    private func loadThumbnail() {
        DispatchQueue.global(qos: .userInitiated).async {
            let image = ThumbnailGenerator.generateThumbnail(for: file, size: CGSize(width: 200, height: 200))
            DispatchQueue.main.async {
                self.thumbnail = image
            }
        }
    }
}
