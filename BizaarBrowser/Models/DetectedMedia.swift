import Foundation

struct DetectedMedia: Identifiable {
    let id = UUID()
    let url: URL
    let filename: String
    let mediaType: MediaType
    let sourcePageURL: URL?

    var fileExtension: String {
        url.pathExtension.lowercased()
    }

    var displayName: String {
        filename.isEmpty ? url.lastPathComponent : filename
    }
}
