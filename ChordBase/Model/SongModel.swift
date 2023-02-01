//
//  SongModel.swift
//  ChordBase
//
//  Created by Lindar Olostur on 28.07.2022.
//

import Foundation
import SwiftUI

struct Song: Codable, Hashable, Identifiable {
    var id = UUID()
    var author = ""
    var name: String = ""
    var textSize = 15.0
    var time: Int = 90
    var text: String = ""
    var isSharp: Bool = true
    var isFavorite: Bool = false
    var tags: [Tag] = []
    var fontName = "San Francisco"
    var textAlignment = 0
    var bgPic = "bg0"
    var picFromGallery = ""
    var fnColor: [Float] = [1, 0, 0, 0]
    var bgColor: [Float] = [1, 1, 1, 1]
    var isBold = false
    var isItalic = false
    var withTitles = false
    var lineSpace: Double = 3
    var scale = 1.0
    var blur = 0.0
    var rotation = 0.0
    var rate = 0
}

struct Tag: Codable, Hashable, Identifiable {
    var id = UUID()
    var name: String = ""
}
