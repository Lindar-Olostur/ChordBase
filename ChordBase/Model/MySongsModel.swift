//
//  MySongsModel.swift
//  ChordBase
//
//  Created by Lindar Olostur on 28.07.2022.
//

import Foundation

struct MyList: Codable {
    var songs: [Song] = []
    var url = "https://www.google.com"
    var editTextHidden = false
    var editBackHidden = false
    var leftHanded = false
    var isDarkMode = false
}
