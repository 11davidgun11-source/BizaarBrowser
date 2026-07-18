import SwiftUI

struct GalleryView: View {
    @EnvironmentObject var downloadManager: DownloadManager
    @EnvironmentObject var settings: AppSettings
    @State private var selectedFile: MediaFile?
    @State private var showViewer = false

    private let columns = [
        GridItem(.adaptive(minimum: 100, maximum: 150), spacing: 6)
    ]

    var filteredFiles: [MediaFile] {
        var files = downloadManager.downloadedFiles

        if settings.filterType != .all {
            files = files.filter { $0.mediaType == settings.filterType }
        }

        switch settings.sortOption {
        case .dateNewest: files.sort { $0.dateAdded > $1.dateAdded }
        case .dateOldest: files.sort { $0.dateAdded < $1.dateAdded }
        case .nameAZ: files.sort { $0.filename.lowercased() < $1.filename.lowercased() }
        case .nameZA: files.sort { $0.filename.lowercased() > $1.filename.lowercased() }
        case .sizeLargest: files.sort { $0.fileSize > $1.fileSize }
        case .sizeSmallest: files.sort { $0.fileSize < $1.fileSize }
        }

        return files
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                GalleryFilterBar()

                if filteredFiles.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 6) {
                            ForEach(filteredFiles) { file in
                                ThumbnailCell(file: file)
                                    .onTapGesture {
                                        selectedFile = file
                                        showViewer = true
                                    }
                            }
                        }
                        .padding(6)
                    }
                }
            }
            .navigationTitle("Gallery")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text("\(filteredFiles.count) files")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .fullScreenCover(isPresented: $showViewer) {
                if let file = selectedFile {
                    MediaViewer(
                        files: filteredFiles,
                        initialFile: file
                    )
                }
            }
            .onAppear {
                downloadManager.loadFiles()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundColor(.gold.opacity(0.5))

            Text("No media yet")
                .font(.title3.bold())

            Text("Download media from the browser\nto see it here")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
