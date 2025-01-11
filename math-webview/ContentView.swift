//
//  ContentView.swift
//  math-webview
//
//  Created by Bill Parks on 1/11/25.
//

import SwiftUI
@preconcurrency
import WebKit

struct RestrictedWebView: UIViewRepresentable {
    let allowedDomains: [String] // e.g., ["example.com", "example.org"]
    let url: URL

    func makeCoordinator() -> Coordinator {
        Coordinator(allowedDomains: allowedDomains)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // No updates needed for now
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let allowedDomains: [String]

        init(allowedDomains: [String]) {
            self.allowedDomains = allowedDomains
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let host = navigationAction.request.url?.host {
                if allowedDomains.contains(where: host.contains) {
                    decisionHandler(.allow)
                } else {
                    decisionHandler(.cancel)
                }
            } else {
                decisionHandler(.cancel)
            }
        }
    }
}

struct ContentView: View {
    var body: some View {
        RestrictedWebView(
            allowedDomains: ["mathacademy.com"],
            url: URL(string: "https://mathacademy.com/login")!
        )
    }
}
