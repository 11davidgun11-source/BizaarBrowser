import Foundation
import WebKit

class MediaDetector: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
    weak var webView: WKWebView?
    @Published var detectedMedia: [DetectedMedia] = []

    private let mediaExtensions = ["jpg", "jpeg", "png", "gif", "webm", "mp4"]
    private var currentURL: URL?

    func configure(webView: WKWebView) {
        self.webView = webView
        webView.navigationDelegate = self

        let script = WKUserScript(source: mediaDetectionJS, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        webView.configuration.userContentController.addUserScript(script)
        webView.configuration.userContentController.add(self, name: "mediaDetected")
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        currentURL = webView.url
        injectMediaDetection()
    }

    func injectMediaDetection() {
        webView?.evaluateJavaScript(mediaDetectionJS) { [weak self] _, error in
            if let error = error {
                print("Media detection JS error: \(error)")
            }
        }
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "mediaDetected",
              let body = message.body as? [String: Any],
              let urlString = body["url"] as? String,
              let url = URL(string: urlString) else { return }

        let ext = url.pathExtension.lowercased()
        guard mediaExtensions.contains(ext) else { return }

        let mediaType: MediaType
        switch ext {
        case "jpg", "jpeg", "png": mediaType = .image
        case "mp4", "webm": mediaType = .video
        case "gif": mediaType = .gif
        default: return
        }

        let filename = url.deletingPathExtension().lastPathComponent
        let detected = DetectedMedia(
            url: url,
            filename: filename,
            mediaType: mediaType,
            sourcePageURL: currentURL
        )

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if !self.detectedMedia.contains(where: { $0.url == url }) {
                self.detectedMedia.append(detected)
            }
        }
    }

    func clearDetected() {
        detectedMedia = []
    }

    private var mediaDetectionJS: String {
        """
        (function() {
            var media = [];

            // Detect 4chan/i.4cdn.org images and videos
            document.querySelectorAll('a.fileThumb, a[href*="i.4cdn.org"]').forEach(function(el) {
                var href = el.href || el.getAttribute('href');
                if (href) {
                    media.push({url: href, source: '4chan'});
                }
            });

            // Detect standard media elements
            document.querySelectorAll('img[src], video source[src], video[src]').forEach(function(el) {
                var src = el.src || el.getAttribute('src');
                if (src && !src.startsWith('data:')) {
                    media.push({url: src, source: 'element'});
                }
            });

            // Detect background images
            document.querySelectorAll('[style*="background-image"]').forEach(function(el) {
                var match = el.style.backgroundImage.match(/url\\(['"]?(.+?)['"]?\\)/);
                if (match && match[1]) {
                    media.push({url: match[1], source: 'bg'});
                }
            });

            // Detect links to media files
            document.querySelectorAll('a[href]').forEach(function(el) {
                var href = el.href;
                if (href && /\\.(jpg|jpeg|png|gif|webm|mp4)(\\?.*)?$/i.test(href)) {
                    media.push({url: href, source: 'link'});
                }
            });

            // Send to native
            media.forEach(function(m) {
                window.webkit.messageHandlers.mediaDetected.postMessage(m);
            });
        })();
        """
    }
}
