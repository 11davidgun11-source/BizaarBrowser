import UIKit
import AVFoundation
import ImageIO

enum ThumbnailGenerator {
    static func generateThumbnail(for mediaFile: MediaFile, size: CGSize = CGSize(width: 200, height: 200)) -> UIImage? {
        switch mediaFile.mediaType {
        case .image:
            return imageThumbnail(for: mediaFile.url, size: size)
        case .video:
            return videoThumbnail(for: mediaFile.url, size: size)
        case .gif:
            return gifThumbnail(for: mediaFile.url, size: size)
        case .all:
            return imageThumbnail(for: mediaFile.url, size: size)
        }
    }

    static func videoDuration(for url: URL) -> Double? {
        let asset = AVURLAsset(url: url)
        let duration = asset.duration
        guard duration.isValid && !duration.isIndefinite else { return nil }
        return CMTimeGetSeconds(duration)
    }

    private static func imageThumbnail(for url: URL, size: CGSize) -> UIImage? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
        let options: [CFString: Any] = [
            kCGImageSourceThumbnailMaxPixelSize: max(size.width, size.height),
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true
        ]
        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else { return nil }
        return UIImage(cgImage: cgImage)
    }

    private static func videoThumbnail(for url: URL, size: CGSize) -> UIImage? {
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.maximumSize = size
        generator.appliesPreferredTrackTransform = true

        do {
            let cgImage = try generator.copyCGImage(at: .zero, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            do {
                let cgImage = try generator.copyCGImage(at: CMTime(seconds: 1, preferredTimescale: 600), actualTime: nil)
                return UIImage(cgImage: cgImage)
            } catch {
                return nil
            }
        }
    }

    private static func gifThumbnail(for url: URL, size: CGSize) -> UIImage? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
        let options: [CFString: Any] = [
            kCGImageSourceThumbnailMaxPixelSize: max(size.width, size.height),
            kCGImageSourceCreateThumbnailFromImageAlways: true
        ]
        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
