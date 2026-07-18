import SwiftUI

struct BrowserView: View {
    @EnvironmentObject var downloadManager: DownloadManager
    @EnvironmentObject var settings: AppSettings
    @StateObject private var browserState = BrowserState()
    @Binding var selectedTab: Int

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            WebViewContainer(browserState: browserState, settings: settings)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                if !settings.isBrowserChromeHidden {
                    AddressBar(text: $browserState.urlText, onCommit: {
                        browserState.navigateTo(text: browserState.urlText)
                    })
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                Spacer()

                HStack {
                    Spacer()
                    TabBarOverlay(selectedTab: $selectedTab)
                }
                .padding(.bottom, 4)
                .padding(.horizontal, 40)
                .opacity(settings.isBrowserChromeHidden ? 0 : 1)
                .offset(y: settings.isBrowserChromeHidden ? 60 : 0)
            }
            .ignoresSafeArea(edges: .bottom)
            .allowsHitTesting(!settings.isBrowserChromeHidden)

            if browserState.isLoading {
                VStack {
                    Spacer()
                    ProgressView(value: browserState.estimatedProgress)
                        .progressViewStyle(.linear)
                        .tint(.gold)
                        .frame(height: 2)
                        .offset(y: settings.isBrowserChromeHidden ? 0 : -48)
                }
                .ignoresSafeArea(edges: .bottom)
            }

            if !browserState.mediaDetector.detectedMedia.isEmpty {
                MediaFAB(count: browserState.mediaDetector.detectedMedia.count) {
                    browserState.showMediaSheet = true
                }
                .padding(.trailing, 16)
                .padding(.bottom, settings.isBrowserChromeHidden ? 20 : 60)
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

struct TabBarOverlay: View {
    @Binding var selectedTab: Int

    var body: some View {
        HStack(spacing: 0) {
            tabButton(icon: "globe", title: "Browser", tag: 0)
            tabButton(icon: "square.grid.2x2", title: "Gallery", tag: 1)
            tabButton(icon: "gearshape", title: "Settings", tag: 2)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.15), radius: 8, y: 2)
    }

    private func tabButton(icon: String, title: String, tag: Int) -> some View {
        Button {
            selectedTab = tag
        } label: {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                Text(title)
                    .font(.system(size: 9))
            }
            .foregroundColor(selectedTab == tag ? .gold : .secondary)
            .frame(maxWidth: .infinity)
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
