import SwiftUI

struct BrowserView: View {
    @EnvironmentObject var downloadManager: DownloadManager
    @EnvironmentObject var settings: AppSettings
    @StateObject private var browserState = BrowserState()

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                    AddressBar(text: $browserState.urlText, onCommit: {
                        browserState.navigateTo(text: browserState.urlText)
                    })
                    .offset(y: settings.isBrowserChromeHidden ? -80 : 0)
                    .opacity(settings.isBrowserChromeHidden ? 0 : 1)
                    .zIndex(1)

                    ZStack {
                        WebViewContainer(browserState: browserState, settings: settings)

                        if browserState.isLoading {
                            ProgressView(value: browserState.estimatedProgress)
                                .progressViewStyle(.linear)
                                .tint(.gold)
                                .frame(height: 2)
                        }
                    }
                }

                if !browserState.mediaDetector.detectedMedia.isEmpty {
                    MediaFAB(count: browserState.mediaDetector.detectedMedia.count) {
                        browserState.showMediaSheet = true
                    }
                    .padding(.trailing, 16)
                    .padding(.bottom, settings.isBrowserChromeHidden ? 20 : 24)
                    .transition(.scale.combined(with: .opacity))
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
            .sheet(isPresented: $browserState.showMediaSheet) {
                MediaSheetView(
                    media: browserState.mediaDetector.detectedMedia,
                    onDownload: { media in
                        downloadManager.download(media: media)
                    },
                    onDownloadAll: {
                        for media in browserState.mediaDetector.detectedMedia {
                            downloadManager.download(media: media)
                        }
                    }
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
    }
}

struct MediaFAB: View {
    let count: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Circle()
                    .fill(Color.gold)
                    .frame(width: 56, height: 56)
                    .shadow(color: .black.opacity(0.25), radius: 6, y: 3)

                Image(systemName: "photo.stack")
                    .font(.title2)
                    .foregroundColor(.white)

                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.red)
                        .clipShape(Capsule())
                        .offset(x: 6, y: -6)
                }
            }
        }
    }
}
