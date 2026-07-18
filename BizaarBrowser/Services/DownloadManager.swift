import Foundation
import Combine

class DownloadManager: ObservableObject {
    static let shared = DownloadManager()

    @Published var downloadedFiles: [MediaFile] = []
    @Published var activeDownloads: [String: Double] = [:]

    private let fileManager = FileManager.default
    private var bizaarMediaURL: URL {
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("BizaarMedia", isDirectory: true)
    }

    private init() {
        ensureDirectoryExists()
        loadFiles()
    }

    func ensureDirectoryExists() {
        if !fileManager.fileExists(atPath: bizaarMediaURL.path) {
            try? fileManager.createDirectory(at: bizaarMediaURL, withIntermediateDirectories: true)
        }
    }

    func loadFiles() {
        guard let contents = try? fileManager.contentsOfDirectory(
            at: bizaarMediaURL,
            includingPropertiesForKeys: [.creationDateKey, .fileSizeKey],
            options: [.skipsHiddenFiles]
        ) else {
            downloadedFiles = []
            return
        }

        downloadedFiles = contents
            .filter { !$0.hasDirectoryPath }
            .map { MediaFile(url: $0) }
    }

    func download(media: DetectedMedia) {
        let filename = sanitizeFilename(media.filename)
        let ext = media.fileExtension.isEmpty ? "bin" : media.fileExtension
        let destinationURL = uniqueURL(for: filename, extension: ext, in: bizaarMediaURL)

        activeDownloads[media.url.absoluteString] = 0

        let task = URLSession.shared.downloadTask(with: media.url) { [weak self] tempURL, response, error in
            guard let self = self, let tempURL = tempURL, error == nil else {
                DispatchQueue.main.async {
                    self?.activeDownloads.removeValue(forKey: media.url.absoluteString)
                }
                return
            }

            do {
                try self.fileManager.copyItem(at: tempURL, to: destinationURL)

                if self.shouldConvert(media: media) {
                    self.convertWebMToMP4(at: destinationURL)
                }

                DispatchQueue.main.async {
                    self.activeDownloads.removeValue(forKey: media.url.absoluteString)
                    self.loadFiles()
                }
            } catch {
                DispatchQueue.main.async {
                    self.activeDownloads.removeValue(forKey: media.url.absoluteString)
                }
            }
        }

        task.resume()
    }

    private func shouldConvert(media: DetectedMedia) -> Bool {
        return AppSettings.shared.convertWebMToMP4 && media.fileExtension == "webm"
    }

    func convertWebMToMP4(at url: URL) {
        let mp4URL = url.deletingPathExtension().appendingPathExtension("mp4")

        FFmpegWrapper.convert(input: url, output: mp4URL) { [weak self] success in
            if success {
                try? self?.fileManager.removeItem(at: url)
                DispatchQueue.main.async {
                    self?.loadFiles()
                }
            }
        }
    }

    func delete(file: MediaFile) {
        try? fileManager.removeItem(at: file.url)
        loadFiles()
    }

    func deleteAll() {
        for file in downloadedFiles {
            try? fileManager.removeItem(at: file.url)
        }
        downloadedFiles = []
    }

    func rename(file: MediaFile, to newName: String) {
        let ext = file.fileExtension
        let newURL = file.url.deletingLastPathComponent()
            .appendingPathComponent(sanitizeFilename(newName))
            .appendingPathExtension(ext)

        guard newURL != file.url else { return }

        do {
            try fileManager.moveItem(at: file.url, to: newURL)
            loadFiles()
        } catch {}
    }

    private func sanitizeFilename(_ name: String) -> String {
        let invalidChars = CharacterSet(charactersIn: ":/\\?%*|\"<>")
        return name.components(separatedBy: invalidChars).joined(separator: "_")
    }

    private func uniqueURL(for filename: String, extension ext: String, in directory: URL) -> URL {
        var url = directory.appendingPathComponent(filename).appendingPathExtension(ext)
        var counter = 1
        while fileManager.fileExists(atPath: url.path) {
            url = directory
                .appendingPathComponent("\(filename)_\(counter)")
                .appendingPathExtension(ext)
            counter += 1
        }
        return url
    }
}
