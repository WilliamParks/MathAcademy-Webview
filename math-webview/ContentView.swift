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
        let configuration = WKWebViewConfiguration()
        
        // Enable cookie storage
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        if let savedCookies = UserDefaults.standard.array(forKey: "savedCookies") as? [[HTTPCookiePropertyKey: Any]] {
            let cookieStore = WKWebsiteDataStore.default().httpCookieStore
            for cookieProperties in savedCookies {
                if let cookie = HTTPCookie(properties: cookieProperties) {
                    cookieStore.setCookie(cookie)
                }
            }
        }
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }
    
    private func loadCookies(completion: @escaping () -> Void) {
        completion()
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
    
    static func saveCookies() {
        let cookieStore = WKWebsiteDataStore.default().httpCookieStore
        cookieStore.getAllCookies { cookies in
            let cookieArray = cookies.map { $0.properties ?? [:] }
            UserDefaults.standard.set(cookieArray, forKey: "savedCookies")
        }
    }
    
    static func restoreCookies() {
        if let savedCookies = UserDefaults.standard.array(forKey: "savedCookies") as? [[HTTPCookiePropertyKey: Any]] {
            let cookieStore = WKWebsiteDataStore.default().httpCookieStore
            for cookieProperties in savedCookies {
                if let cookie = HTTPCookie(properties: cookieProperties) {
                    cookieStore.setCookie(cookie)
                }
            }
        }
    }
}

struct ContentView: View {
    var body: some View {
        RestrictedWebView(
            allowedDomains: ["mathacademy.com"],
            url: URL(string: "https://mathacademy.com/")!
        ).onAppear {
            RestrictedWebView.restoreCookies()
        }
        .onDisappear {
            RestrictedWebView.saveCookies()
        }
    }
}
