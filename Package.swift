// swift-tools-version:5.7
import PackageDescription

// This Package.swift is optional - the project builds via Xcode directly.
// To enable WebM-to-MP4 conversion, add ffmpeg-kit via Xcode:
// File > Add Packages > https://github.com/nicklama/ffmpeg-kit-ios-full
// Or bundle a static ffmpeg binary into the app target.

let package = Package(
    name: "BizaarBrowser",
    platforms: [.iOS(.v15)],
    targets: [
        .executableTarget(
            name: "BizaarBrowser",
            dependencies: [],
            path: "BizaarBrowser"
        )
    ]
)
