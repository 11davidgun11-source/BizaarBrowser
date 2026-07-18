import Foundation
#if canImport(ffmpegkit)
import ffmpegkit
#endif

enum FFmpegWrapper {
    static func convert(input: URL, output: URL, completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            #if canImport(ffmpegkit)
            let session = FFmpegKit.execute("-i \"\(input.path)\" -c:v libx264 -preset fast -crf 23 -c:a aac -b:a 128k -movflags +faststart -y \"\(output.path)\"")
            let returnCode = session?.getReturnCode()
            let success = ReturnCode.isSuccess(returnCode)
            #else
            let success = false
            #endif
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }

    static func generateThumbnail(from videoURL: URL, outputURL: URL, time: Double = 1.0) -> Bool {
        #if canImport(ffmpegkit)
        let session = FFmpegKit.execute("-i \"\(videoURL.path)\" -ss \(time) -vframes 1 -vf scale=200:-1 -y \"\(outputURL.path)\"")
        let returnCode = session?.getReturnCode()
        return ReturnCode.isSuccess(returnCode)
        #else
        return false
        #endif
    }
}
