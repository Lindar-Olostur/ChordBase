//
//  ChordBaseApp.swift
//  ChordBase
//
//  Created by Lindar Olostur on 28.07.2022.
//

import SwiftUI
extension UIDevice {
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var isIPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
}
@main
struct ChordBaseApp: App {
    @StateObject var archive: Archive = Archive()
    var body: some Scene {
        WindowGroup {
            SongListView().environmentObject(archive)
        }
    }
}
