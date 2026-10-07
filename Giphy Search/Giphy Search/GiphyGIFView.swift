import SwiftUI
import WebKit

struct GiphyGIFView: UIViewRepresentable {

    let url: URL

    var contentMode: UIView.ContentMode = .scaleAspectFill

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()

        configuration.allowsInlineMediaPlayback = true

        let webView = WKWebView(
            frame: .zero,
            configuration: configuration
        )

        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false

        return webView
    }

    func updateUIView(
        _ webView: WKWebView,
        context: Context
    ) {
        guard webView.url != url else {
            return
        }

        let request = URLRequest(
            url: url,
            cachePolicy: .returnCacheDataElseLoad,
            timeoutInterval: 30
        )

        webView.load(request)
    }
}
