import SwiftUI

struct BrowserView: View {
    @EnvironmentObject var downloadManager: DownloadManager
    @EnvironmentObject var settings: AppSettings
    @StateObject private var browserState = BrowserState()
    @State private var showMediaOverlay = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    AddressBar(text: $browserState.urlText, onCommit: {
                        browserState.navigateTo(text: browserState.urlText)
                    })

                    ZStack {
                        WebViewContainer(browserState: browserState)

                        if browserState.isLoading {
                            ProgressView(value: browserState.estimatedProgress)
                                .progressViewStyle(.linear)
                                .tint(.gold)
                        }
                    }
                }

                if showMediaOverlay && !browserState.mediaDetector.detectedMedia.isEmpty {
                    MediaOverlay(
                        media: browserState.mediaDetector.detectedMedia,
                        onDownload: { media in
                            downloadManager.download(media: media)
                        },
                        onDismiss: {
                            showMediaOverlay = false
                        }
                    )
                    .transition(.move(edge: .bottom))
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                if settings.lastVisitedURL.isEmpty {
                    browserState.navigateTo(text: "https://boards.4channel.org")
                } else if browserState.currentURL == nil {
                    browserState.navigateTo(text: settings.lastVisitedURL)
                }
            }
            .onChange(of: browserState.currentURL) { url in
                if let url = url {
                    settings.lastVisitedURL = url.absoluteString
                }
            }
            .onChange(of: browserState.mediaDetector.detectedMedia.count) { count in
                withAnimation(.spring()) {
                    showMediaOverlay = count > 0
                }
            }
        }
    }
}
