import Foundation
#if canImport(ffmpegkit)
import ffmpegkit
#endif

enum FFmpegWrapper {
    static func convert(input: URL, output: URL, completion: @escaping (Bool) -> Void) {
        #if canImport(ffmpegkit)
        let session = FFmpegKit.execute("-i \"\(input.path)\" -c:v libx264 -preset fast -crf 23 -c:a aac -b:a 128k -movflags +faststart -y \"\(output.path)\"")
        let returnCode = session?.getReturnCode()
        DispatchQueue.main.async {
            completion(ReturnCode.isSuccess(returnCode))
        }
        #else
        convertViaProcess(input: input, output: output, completion: completion)
        #endif
    }

    static func generateThumbnail(from videoURL: URL, outputURL: URL, time: Double = 1.0) -> Bool {
        #if canImport(ffmpegkit)
        let session = FFmpegKit.execute("-i \"\(videoURL.path)\" -ss \(time) -vframes 1 -vf scale=200:-1 -y \"\(outputURL.path)\"")
        let returnCode = session?.getReturnCode()
        return ReturnCode.isSuccess(returnCode)
        #else
        return generateThumbnailViaProcess(from: videoURL, outputURL: outputURL, time: time)
        #endif
    }

    private static func convertViaProcess(input: URL, output: URL, completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let process = Process()
            let pipe = Pipe()

            let ffmpegPath = Bundle.main.path(forResource: "ffmpeg", ofType: nil)
                ?? "/usr/local/bin/ffmpeg"

            process.executableURL = URL(fileURLWithPath: ffmpegPath)
            process.arguments = [
                "-i", input.path,
                "-c:v", "libx264",
                "-preset", "fast",
                "-crf", "23",
                "-c:a", "aac",
                "-b:a", "128k",
                "-movflags", "+faststart",
                "-y",
                output.path
            ]
            process.standardOutput = pipe
            process.standardError = pipe

            do {
                try process.run()
                process.waitUntilExit()
                let success = process.terminationStatus == 0
                DispatchQueue.main.async {
                    completion(success)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }

    private static func generateThumbnailViaProcess(from videoURL: URL, outputURL: URL, time: Double = 1.0) -> Bool {
        let process = Process()

        let ffmpegPath = Bundle.main.path(forResource: "ffmpeg", ofType: nil)
            ?? "/usr/local/bin/ffmpeg"

        process.executableURL = URL(fileURLWithPath: ffmpegPath)
        process.arguments = [
            "-i", videoURL.path,
            "-ss", "\(time)",
            "-vframes", "1",
            "-vf", "scale=200:-1",
            "-y",
            outputURL.path
        ]

        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus == 0
        } catch {
            return false
        }
    }
}
