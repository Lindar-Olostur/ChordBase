//
//  fromWeb.swift
//  IronswornRuleBook
//
//  Created by Lindar Olostur on 13.04.2022.
//

import SwiftUI
import WebKit

struct SwiftUIWebView: UIViewRepresentable {
    typealias UIViewType = WKWebView
    
    let webView: WKWebView
    
    func makeUIView(context: Context) -> WKWebView {
        webView
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
}

final class SwiftUIWebViewModel: ObservableObject {
    
    @Published var urlString = "https://www.google.com"
    
    let webView: WKWebView
    init() {
        webView = WKWebView(frame: .zero)
    }
    
    func back() {
      webView.goBack()
    }
    func forward() {
      webView.goForward()
    }
    func loadUrl(path: String) {
        guard let url = URL(string: path) else {
            return
        }
        webView.load(URLRequest(url: url))
    }
}
