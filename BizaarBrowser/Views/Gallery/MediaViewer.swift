import SwiftUI
import AVKit

struct MediaViewer: View {
    let files: [MediaFile]
    @State var currentFile: MediaFile
    @Environment(\.dismiss) var dismiss

    @State private var showShareSheet = false
    @State private var showDeleteAlert = false
    @State private var showRenameAlert = false
    @State private var renameText = ""

    init(files: [MediaFile], initialFile: MediaFile) {
        self.files = files
        _currentFile = State(initialValue: initialFile)
    }

    private var currentIndex: Int {
        files.firstIndex(where: { $0.id == currentFile.id }) ?? 0
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(12)
                    }

                    Spacer()

                    VStack {
                        Text(currentFile.filename)
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Text("\(currentIndex + 1) of \(files.count)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    Menu {
                        Button(action: {
                            renameText = currentFile.filename
                            showRenameAlert = true
                        }) {
                            Label("Rename", systemImage: "pencil")
                        }

                        Button(action: { showShareSheet = true }) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }

                        Button(role: .destructive, action: { showDeleteAlert = true }) {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(12)
                    }
                }

                Spacer()

                TabView(selection: $currentFile) {
                    ForEach(files) { file in
                        MediaContent(file: file)
                            .tag(file)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                Spacer()

                HStack(spacing: 40) {
                    if currentIndex > 0 {
                        Button(action: {
                            withAnimation { currentFile = files[currentIndex - 1] }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                    }

                    Text(FileSizeFormatter.string(from: currentFile.fileSize))
                        .font(.caption)
                        .foregroundColor(.gray)

                    if currentIndex < files.count - 1 {
                        Button(action: {
                            withAnimation { currentFile = files[currentIndex + 1] }
                        }) {
                            Image(systemName: "chevron.right")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .alert("Rename File", isPresented: $showRenameAlert) {
            TextField("New name", text: $renameText)
            Button("Rename") {
                DownloadManager.shared.rename(file: currentFile, to: renameText)
            }
            Button("Cancel", role: .cancel) {}
        }
        .alert("Delete File?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                DownloadManager.shared.delete(file: currentFile)
                if files.count > 1 {
                    let newIndex = min(currentIndex, files.count - 2)
                    currentFile = files[newIndex]
                } else {
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
        .sheet(isPresented: $showShareSheet) {
            if let data = try? Data(contentsOf: currentFile.url) {
                ShareSheet(items: [data])
            }
        }
    }
}

struct MediaContent: View {
    let file: MediaFile

    var body: some View {
        Group {
            switch file.mediaType {
            case .image:
                ImageViewer(file: file)
            case .video:
                VideoPlayerView(file: file)
            case .gif:
                GIFView(file: file)
            case .all:
                EmptyView()
            }
        }
    }
}

struct ImageViewer: View {
    let file: MediaFile
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                ProgressView()
                    .tint(.gold)
            }
        }
        .onAppear {
            DispatchQueue.global(qos: .userInitiated).async {
                let loaded = UIImage(contentsOfFile: file.url.path)
                DispatchQueue.main.async {
                    self.image = loaded
                }
            }
        }
    }
}

struct VideoPlayerView: View {
    let file: MediaFile
    @State private var player: AVPlayer?

    var body: some View {
        Group {
            if let player = player {
                VideoPlayer(player: player)
                    .onAppear { player.play() }
                    .onDisappear { player.pause() }
            } else {
                ProgressView()
                    .tint(.gold)
            }
        }
        .onAppear {
            player = AVPlayer(url: file.url)
            player?.actionAtItemEnd = AppSettings.shared.loopAllAnimations ? .none : .pause

            if AppSettings.shared.loopAllAnimations {
                NotificationCenter.default.addObserver(
                    forName: .AVPlayerItemDidPlayToEndTime,
                    object: player?.currentItem,
                    queue: .main
                ) { _ in
                    player?.seek(to: .zero)
                    player?.play()
                }
            }
        }
    }
}

struct GIFView: View {
    let file: MediaFile
    @State private var frames: [UIImage] = []
    @State private var currentFrameIndex = 0
    @State private var timer: Timer?

    var body: some View {
        Group {
            if !frames.isEmpty {
                Image(uiImage: frames[currentFrameIndex])
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                ProgressView()
                    .tint(.gold)
            }
        }
        .onAppear { loadGIF() }
        .onDisappear { timer?.invalidate() }
    }

    private func loadGIF() {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let source = CGImageSourceCreateWithURL(file.url as CFURL, nil) else { return }
            let count = CGImageSourceGetCount(source)
            var loadedFrames: [UIImage] = []

            for i in 0..<count {
                if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                    loadedFrames.append(UIImage(cgImage: cgImage))
                }
            }

            DispatchQueue.main.async {
                self.frames = loadedFrames
                if loadedFrames.count > 1 {
                    startAnimation()
                }
            }
        }
    }

    private func startAnimation() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            currentFrameIndex = (currentFrameIndex + 1) % frames.count
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
