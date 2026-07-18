import SwiftUI

@main
struct BizaarBrowserApp: App {
    @StateObject private var downloadManager = DownloadManager.shared
    @StateObject private var settings = AppSettings.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(downloadManager)
                .environmentObject(settings)
                .preferredColorScheme(settings.colorScheme)
        }
    }
}
