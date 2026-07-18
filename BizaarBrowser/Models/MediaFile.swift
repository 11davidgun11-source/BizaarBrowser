import Foundation

enum MediaType: String, CaseIterable, Identifiable {
    case all = "All"
    case image = "Images"
    case video = "Videos"
    case gif = "GIFs"

    var id: String { rawValue }

    var extensions: [String] {
        switch self {
        case .all: return []
        case .image: return ["jpg", "jpeg", "png"]
        case .video: return ["mp4", "webm"]
        case .gif: return ["gif"]
        }
    }
}

enum SortOption: String, CaseIterable, Identifiable {
    case dateNewest = "Newest First"
    case dateOldest = "Oldest First"
    case nameAZ = "Name A-Z"
    case nameZA = "Name Z-A"
    case sizeLargest = "Largest First"
    case sizeSmallest = "Smallest First"

    var id: String { rawValue }
}

struct MediaFile: Identifiable, Hashable {
    let id: UUID
    let url: URL
    let filename: String
    let fileExtension: String
    let dateAdded: Date
    let fileSize: Int64

    var mediaType: MediaType {
        switch fileExtension.lowercased() {
        case "jpg", "jpeg", "png": return .image
        case "mp4", "webm": return .video
        case "gif": return .gif
        default: return .image
        }
    }

    var isVideo: Bool {
        mediaType == .video
    }

    var isAnimated: Bool {
        mediaType == .gif || mediaType == .video
    }

    init(url: URL) {
        self.id = UUID()
        self.url = url
        self.filename = url.deletingPathExtension().lastPathComponent
        self.fileExtension = url.pathExtension.lowercased()

        let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
        self.dateAdded = (attributes?[.creationDate] as? Date) ?? Date()
        self.fileSize = (attributes?[.size] as? Int64) ?? 0
    }
}
