import SwiftUI
import WebKit

struct WebViewContainer: UIViewRepresentable {
    @ObservedObject var browserState: BrowserState
    @ObservedObject var settings: AppSettings

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.keyboardDismissMode = .onDrag
        webView.isOpaque = false
        webView.backgroundColor = .systemBackground

        browserState.mediaDetector.configure(webView: webView)
        browserState.webView = webView

        context.coordinator.browserState = browserState
        context.coordinator.settings = settings
        context.coordinator.webView = webView
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.addObserver(context.coordinator, forKeyPath: "estimatedProgress", options: .new, context: nil)
        webView.addObserver(context.coordinator, forKeyPath: "isLoading", options: .new, context: nil)
        webView.scrollView.addObserver(context.coordinator, forKeyPath: "contentOffset", options: .new, context: nil)

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var browserState: BrowserState?
        var settings: AppSettings?
        weak var webView: WKWebView?
        private var previousScrollY: CGFloat = 0
        private var scrollAccumulator: CGFloat = 0
        private var hasReceivedFirstScroll = false

        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            if keyPath == "contentOffset" {
                guard let scrollView = object as? UIScrollView else { return }
                let currentY = scrollView.contentOffset.y

                guard hasReceivedFirstScroll else {
                    previousScrollY = currentY
                    hasReceivedFirstScroll = true
                    return
                }

                guard currentY > 10 else {
                    if settings?.isBrowserChromeHidden == true {
                        DispatchQueue.main.async { [weak self] in
                            withAnimation(.easeOut(duration: 0.25)) {
                                self?.settings?.isBrowserChromeHidden = false
                            }
                        }
                    }
                    scrollAccumulator = 0
                    previousScrollY = currentY
                    return
                }

                let delta = currentY - previousScrollY
                scrollAccumulator += delta

                DispatchQueue.main.async { [weak self] in
                    guard let self = self, let settings = self.settings else { return }
                    if self.scrollAccumulator > 50 && !settings.isBrowserChromeHidden {
                        withAnimation(.easeOut(duration: 0.25)) {
                            settings.isBrowserChromeHidden = true
                        }
                        self.scrollAccumulator = 0
                    } else if self.scrollAccumulator < -30 && settings.isBrowserChromeHidden {
                        withAnimation(.easeOut(duration: 0.25)) {
                            settings.isBrowserChromeHidden = false
                        }
                        self.scrollAccumulator = 0
                    }
                }

                previousScrollY = currentY
                return
            }

            guard let webView = object as? WKWebView else { return }

            DispatchQueue.main.async { [weak self] in
                guard let state = self?.browserState else { return }
                if keyPath == "estimatedProgress" {
                    state.estimatedProgress = webView.estimatedProgress
                }
                if keyPath == "isLoading" {
                    state.isLoading = webView.isLoading
                }
                state.updateNavigationState(webView)
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            browserState?.updateNavigationState(webView)
            browserState?.mediaDetector.injectMediaDetection()
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            decisionHandler(.allow)
        }

        deinit {
            browserState?.webView?.removeObserver(self, forKeyPath: "estimatedProgress")
            browserState?.webView?.removeObserver(self, forKeyPath: "isLoading")
            browserState?.webView?.scrollView.removeObserver(self, forKeyPath: "contentOffset")
        }
    }
}
