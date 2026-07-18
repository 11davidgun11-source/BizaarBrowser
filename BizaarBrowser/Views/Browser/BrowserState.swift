import Foundation
import WebKit

class BrowserState: ObservableObject {
    @Published var urlText: String = ""
    @Published var isLoading: Bool = false
    @Published var estimatedProgress: Double = 0
    @Published var currentURL: URL?
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    @Published var isChromeHidden: Bool = false
    @Published var showMediaSheet: Bool = false

    let mediaDetector = MediaDetector()

    weak var webView: WKWebView?

    func navigateTo(text: String) {
        var urlString = text.trimmingCharacters(in: .whitespacesAndNewlines)

        if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
            if urlString.contains(".") && !urlString.contains(" ") {
                urlString = "https://" + urlString
            } else {
                urlString = "https://www.google.com/search?q=\(urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? urlString)"
            }
        }

        guard let url = URL(string: urlString) else { return }
        webView?.load(URLRequest(url: url))
    }

    func goBack() {
        webView?.goBack()
    }

    func goForward() {
        webView?.goForward()
    }

    func reload() {
        webView?.reload()
    }

    func updateNavigationState(_ webView: WKWebView) {
        canGoBack = webView.canGoBack
        canGoForward = webView.canGoForward
        currentURL = webView.url
        if let url = webView.url {
            urlText = url.absoluteString
        }
    }
}
