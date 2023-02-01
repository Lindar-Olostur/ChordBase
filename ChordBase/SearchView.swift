//
//  SearchView.swift
//  ChordBase
//
//  Created by Lindar Olostur on 17.08.2022.
//

import SwiftUI

struct SearchView: View {
    @Binding var browserIsOpened: Bool
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var archive: Archive
    @StateObject private var model = SwiftUIWebViewModel()
    
    var body: some View {
        VStack {
            HStack {
                Button(action: { model.back() }) {
                    Image(systemName: "arrow.backward")
                }
                Spacer()
//                TextField("Enter url", text: $archive.myList.url)
//                    .textFieldStyle(.roundedBorder)
                Button {
                    model.loadUrl(path: "https://www.google.com")
                } label: {
                    Image(systemName: "house")
                }
                Button {
                    self.browserIsOpened.toggle()
                } label: {
                    Image(systemName: "multiply")
                }.padding(.leading, 30)
                Spacer()
                Button(action: { model.forward() }) {
                    Image(systemName: "arrow.forward")
                }
            }.padding()
            SwiftUIWebView(webView: model.webView)
//            Group {
//                HStack {
//                    TextField("Enter url", text: $model.urlString)
//                        .textFieldStyle(.roundedBorder)
//                    Button("Go") {
//                        model.loadUrl()
//                    }
//                }
//            }
//            .padding(.horizontal)
//            .padding(.vertical, 5)
        }
        .onAppear() {
            model.loadUrl(path: archive.myList.url)
        }
        .onDisappear() {
            archive.myList.url = model.webView.url?.absoluteString
            ?? "https://www.apple.com"
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(browserIsOpened: .constant(false), archive: Archive()).environmentObject(Archive())
    }
}
