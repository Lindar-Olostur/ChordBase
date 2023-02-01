//
//  ColorData.swift
//  ChordBase
//
//  Created by Lindar Olostur on 22.08.2022.
//

import Foundation
import SwiftUI

struct ColorData{
//    private var COLOR_KEY = "COLOR_KEY"
//    private var userDefaults = UserDefaults.standard
    
    func saveColor(color: Color) -> [Float] {
        let color = UIColor(color).cgColor
        
//        if let components = color.components {
//            userDefaults.set(components, forKey: COLOR_KEY)
//        }
        var result: [Float] = []
        for value in color.components ?? [1, 1, 1, 1] {
            result.insert(Float(value), at: 0)
        }
        
        return result
    }
    
    func loadColor(nums: [Float]) -> Color {
        //guard let array = userDefaults.object(forKey: COLOR_KEY) as? [CGFloat] else { return Color.white}
        var array: [CGFloat] = []
        for value in nums {
            array.insert(CGFloat(value), at: 0)
        }
        let color = Color(.sRGB, red: array[0], green: array[1], blue: array[2], opacity: array[3])
        return color
    }
}
