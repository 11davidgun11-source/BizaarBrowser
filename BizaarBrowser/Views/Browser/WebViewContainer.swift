import SwiftUI
import WebKit

struct WebViewContainer: UIViewRepresentable {
    @ObservedObject var browserState: BrowserState

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.keyboardDismissMode = .onDrag

        browserState.mediaDetector.configure(webView: webView)
        browserState.webView = webView

        context.coordinator.browserState = browserState
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.addObserver(context.coordinator, forKeyPath: "estimatedProgress", options: .new, context: nil)
        webView.addObserver(context.coordinator, forKeyPath: "isLoading", options: .new, context: nil)

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var browserState: BrowserState?

        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
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
        }
    }
}
