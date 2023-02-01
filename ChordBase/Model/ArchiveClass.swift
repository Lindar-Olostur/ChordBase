//
//  ArchiveClass.swift
//  ChordBase
//
//  Created by Lindar Olostur on 28.07.2022.
//

import Foundation
import SwiftUI

@MainActor class Archive: ObservableObject {
    @Published var myList = MyList()
    var path = "https://www.google.com"

    func writeToFile() {
        let documentDirectoryPath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let fileUrl = URL(fileURLWithPath: documentDirectoryPath).appendingPathComponent("mySongs.json")
            do{
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                let JsonData = try encoder.encode(myList)
                try JsonData.write(to: fileUrl)
                print("записали файл mySongs.json")
                print(fileUrl)
            } catch {
                print("не получилось записать")
        }
    }
    
    func getFile() {
        myList = readArchive()
    }

    func autoload<T: Decodable>() -> T {
        let data: Data
        let documentDirectoryPath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let fileUrl = URL(fileURLWithPath: documentDirectoryPath)
        let file = fileUrl.absoluteURL.appendingPathComponent("mySongs.json")
        
        do {
            data = try Data(contentsOf: file)
        } catch {
            fatalError("Couldn't load mySongs.json from main bundle:\n\(error)")
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("Couldn't parse mySongs.json as \(T.self):\n\(error)")
        }
    }
    
    func readArchive<T: Decodable>() -> T {
        let data: Data

        guard let file = Bundle.main.url(forResource: "mySongs", withExtension: "json")
        else {
            fatalError("Couldn't find mySongs.json in main bundle.")
        }

        do {
            data = try Data(contentsOf: file)
        } catch {
            fatalError("Couldn't load mySongs.json from main bundle:\n\(error)")
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("Couldn't parse mySongs.json as \(T.self):\n\(error)")
        }
    }
    
    func getPicToBg(id: Song?) -> Image {
        guard id != nil else { return Image("bg0") }
        var pic: Image
        let song = myList.songs[myList.songs.firstIndex(of: id ?? Song()) ?? 0]
        if song.picFromGallery != "" {
            pic = Image(uiImage: song.picFromGallery.toImage() ?? UIImage(imageLiteralResourceName: "bg0"))
        } else {
            pic = Image(song.bgPic)
        }
        return pic
    }
    
    
    func chordDetection(text: String) -> String {
        enum chordLetters: String, CaseIterable {
            case A, B, C, D, E, F, G, H
        }
        var testChord = ""
        var isChord = false
        var chordLetterIsDetected = false
        var bIsDetected = false

        for character in text {
            // find Letter
            for letter in chordLetters.allCases {
                if character == Character(letter.rawValue) {
                    testChord = String(character)
                    chordLetterIsDetected = true
                }
            }
            //check solo Chord
            if chordLetterIsDetected && text.count == 1 {
                isChord = true
            }
            //check key signatures
            if chordLetterIsDetected && String(character) == "#" {
                testChord += "#"
                isChord = true
            }
            if chordLetterIsDetected && String(character) == "b" {
                testChord += "b"
                bIsDetected = true
                //isChord = true
            }
            if chordLetterIsDetected && bIsDetected && text.count <= 5 {
                isChord = true
            }
            // check number
            if chordLetterIsDetected && String(character).rangeOfCharacter(from: CharacterSet.decimalDigits) != nil {
                isChord = true
            }
            // check prefix +
            if chordLetterIsDetected && String(character) == "+" {
                isChord = true
            }
            // check suffixes -dim
            if chordLetterIsDetected && text.hasSuffix("dim") {
                isChord = true
            }
            // check suffixes -sus
            if chordLetterIsDetected && text.hasSuffix("sus") {
                isChord = true
            }
            // check suffixes -add
            if chordLetterIsDetected && text.hasSuffix("add") {
                isChord = true
            }
            // check suffixes -aug
            if chordLetterIsDetected && text.hasSuffix("aug") {
                isChord = true
            }
            // check suffixes -min
            if chordLetterIsDetected && text.hasSuffix("min") {
                isChord = true
            }
            // check suffixes -maj
            if chordLetterIsDetected && text.hasSuffix("maj") {
                isChord = true
            }
            // check suffixes -m
            if chordLetterIsDetected && text.hasSuffix("m") {
                isChord = true
            }
            // check suffixes -M
            if chordLetterIsDetected && text.hasSuffix("M") {
                isChord = true
            }
            //check solo Chord at end of new line
            if chordLetterIsDetected && String(character) == "\n" && text.count <= 5 {
                isChord = true
            }
        }
        if isChord {
            return testChord
        } else {
            return ""
        }
    }
}
