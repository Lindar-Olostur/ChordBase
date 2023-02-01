//
//  ChordModel.swift
//  ChordBase
//
//  Created by Lindar Olostur on 13.08.2022.
//

import Foundation
import SwiftyChords

struct Chord: Hashable, Identifiable {
    var id = UUID()
    var key: String
    var trueKey: String
    var suffix: String
    var trueSuffix: String
}
