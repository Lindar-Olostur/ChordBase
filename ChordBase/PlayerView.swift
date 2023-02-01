//
//  PlayerView.swift
//  ChordBase
//
//  Created by Lindar Olostur on 05.08.2022.
//

import SwiftUI
import SwiftyChords

public struct DarkView<Content> : View where Content : View {
    var darkContent: Content
    var on: Bool
    public init(_ on: Bool, @ViewBuilder content: () -> Content) {
        self.darkContent = content()
        self.on = on
    }

    public var body: some View {
        ZStack {
            if on {
                Spacer()
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .background(Color.black)
                    .edgesIgnoringSafeArea(.all)
                darkContent.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity).background(Color.black).colorScheme(.dark)
            } else {
                darkContent
            }
        }
    }
}

extension View {
    public func darkModeFix(_ on: Bool = true) -> DarkView<Self> {
        DarkView(on) {
            self
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}
struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct PlayerView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @State var scrollPosition: CGFloat = 0.0
    let alignments: [TextAlignment] = [.leading, .center, .trailing]
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    @State var timerIsRunning = false
    @State var chordSchemeIsOpened = false
    @State var chordsInSong: [Chord] = []
    @Binding var song: Song
    @ObservedObject var archive: Archive
    var chord = CAShapeLayer()
    @State var isLeftHanded = false
    var columns: [GridItem] = [
        GridItem(.adaptive(minimum: 80))
    ]
    @State var bgColor = Color.white
    @State var fnColor = Color.black
    var bgColorData = ColorData()
    var fnColorData = ColorData()
    
    init(song: Binding<Song>, archive: Archive) {
        _song = song
        self.archive = archive
        UITextView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        
        ZStack {
            VStack {
                Slider(value: $scrollPosition)
                    .onReceive(timer) { _ in
                        if scrollPosition < 1.0 && timerIsRunning {
                            //countDownTimer -= 0.01
                            scrollPosition += 0.0101 / CGFloat(song.time)
                        } else {
                            timerIsRunning = false
                        }
                    }
                    .allowsHitTesting(false)
                    .opacity(0.0)
            }
            if timerIsRunning == false {
                VStack {
                    Button {
                        self.presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "multiply.circle" )
                            //.colorMultiply(.red).opacity(0.5)
                            .accessibility(identifier: "StopInPlayer")
                            .foregroundColor(.red)
                            .font(.system(size: 60))
                            .opacity(0.7)
                    }
                    .allowsHitTesting(true)
                    .zIndex(1)
                    .padding(.top, UIDevice.isIPad ? 120 : 30)
                    Spacer()
                    Button {
                        timerIsRunning = true
                    } label: {
                        Image(systemName: "play.fill" )
                            .font(.system(size: 200))
                            .opacity(0.4)
                    }
                    .accessibility(identifier: "PlayInPlayer")
                    .allowsHitTesting(true)
                    .zIndex(1)
                    Spacer()
                    Button {
                        //print(colorScheme)
                        chordsInSong = getChords()
                        chordsInSong.sort {
                            $0.key < $1.key
                        }
                        withAnimation(.easeIn(duration: 0.15)) {
                            chordSchemeIsOpened.toggle()
                        }
                    } label: {
                        Text("CHORDS")
                            .font(.system(size: 30))
                            .tint(.white)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue).opacity(0.6)
                    .allowsHitTesting(true)
                    .zIndex(1)
                    .padding(UIDevice.isIPad ? 100 : 0)
                }
            }
            VStack {
                if chordSchemeIsOpened {
                    VStack {
                        HStack {
//                            Toggle(isOn: $archive.myList.guitarChords) {
//                                Text("Guitar")
//                            }
//                            Button {
//                                isLeftHanded.toggle()
//                            } label: {
//                                Text("Change hand")
//                                    .buttonStyle(.bordered)
//                            }
                        }
                        LazyVGrid(columns: columns, alignment: .center, spacing: 0) {
                            ForEach(chordsInSong, id: \.id) { chord in
                                let key = Chords.Key(rawValue: chord.key)
                                let suffix = Chords.Suffix(rawValue: chord.suffix)
                                if key != nil {
                                    let chordPosition = Chords.guitar.matching(key: key!).matching(suffix: suffix!).first
                                    let frame = CGRect(x: 0, y: 0, width: 80, height: 130)
                                    if chordPosition != nil {
                                        let layer = chordPosition!.shapeLayer(rect: frame, showChordName: false, forPrint: true, mirror: isLeftHanded)
                                        VStack {
                                            Text("\(chord.trueKey)\(chord.trueSuffix)")
                                                .font(.system(size: 13))
                                                .padding(.bottom, -6)
                                                .foregroundColor(.black)
                                            Image(uiImage: layer.image()!)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.top, 35)
                        .padding(.bottom)
                        .background(Color.white)
                    }
                    .background(Color.blue)
                    .transition(.asymmetric(insertion: .move(edge: .top), removal: .move(edge: .top)))
                    .cornerRadius(15, corners: [.bottomLeft, .bottomRight])
                    .shadow(radius: 10)
                    .ignoresSafeArea()
                }
                HStack {
                }
                VStack {
                    ScrollView(showsIndicators: false) {
                        ScrollViewReader { scrollProxy in
                            Text("\n\n\n\n\n\n\n\n\(song.text)\n\n\n\n\n\n\n\n")
                                .lineSpacing(song.lineSpace)
                                .multilineTextAlignment(alignments[song.textAlignment])
                                .foregroundColor(fnColor)
                                .background(bgColor.opacity(0))
                                .font(.custom(song.fontName, size: song.textSize))
                                .id("text")
                                .padding(.horizontal, 15)
                                .onChange(of: scrollPosition) { newScrollPosition in
                                    scrollProxy.scrollTo("text", anchor: UnitPoint(x: 15, y: newScrollPosition))
                                }
                        }
                    }
                    .onTapGesture(count: 1) {
                        timerIsRunning = false
                        }
                    .allowsHitTesting(timerIsRunning)
                }
            }
            .zIndex(-2)
        }
        
        .background(archive.getPicToBg(id: song).scaleEffect(song.scale).blur(radius: song.blur).rotationEffect(.degrees(song.rotation)))
        .background(bgColor)
        .onChange(of: bgColor) { newValue in
            song.bgColor = bgColorData.saveColor(color: newValue)
        }
        .onChange(of: fnColor) { newValue in
            song.fnColor = fnColorData.saveColor(color: newValue)
        }
        .onAppear() {
            bgColor = bgColorData.loadColor(nums: song.bgColor)
            fnColor = fnColorData.loadColor(nums: song.fnColor)
        }
    }
    func getChords() -> [Chord] {
        var chordsInSong: [Chord] = []
        var text = song.text
        //print(text)
        text = text.replacingOccurrences(of: "\t", with: " \t ")
        text = text.replacingOccurrences(of: "\n", with: " \n ")
        text = text.replacingOccurrences(of: "\r", with: " \r ")
        //text = text.replacingOccurrences(of: "/", with: " / ")
        //text = text.replacingOccurrences(of: "(", with: " ( ")
        let uniqueParts = text.components(separatedBy: " ")
        let parts = Array(Set(uniqueParts))
        for word in parts {
            let chord = findChord(word: word)
            if chord[0] != "" && chord[1] != "" {
                chordsInSong.append(Chord(key: chord[0], trueKey: chord[2], suffix: chord[1], trueSuffix: chord[3]))
            }
        }
        return chordsInSong
    }
    
    func findChord(word: String) -> [String] {
        enum chordLetters: String, CaseIterable {
            case A, B, C, D, E, F, G, H
        }
        var text = word
        var trueKey = ""
        var trueSuffix = ""
        var key = "" {
            didSet {
                trueKey = key
                if key == "Db" {
                    trueKey = "Db"
                    key = "C#"
                }
                if key == "G#" {
                    trueKey = "G#"
                    key = "Ab"
                }
                if key == "A#" {
                    trueKey = "A#"
                    key = "Bb"
                }
                if key == "D#" {
                    trueKey = "D#"
                    key = "Eb"
                }
//                if key == "D#" {
//                    trueKey = oldValue
//                    key = "Eb"
//                }
                if key == "Gb" {
                    trueKey = "Gb"
                    key = "F#"
                }
            }
        }
        var suffix = "" {
            didSet {
                trueSuffix = suffix
                if suffix == "minor" { trueSuffix = "m" }
                if suffix == "major" { trueSuffix = "" }
            }
        }
        // get a chord key and suffix
        for (index, character) in text.enumerated() {
            if index == 0 {
                for letter in chordLetters.allCases {
                    if character == Character(letter.rawValue) {
                        key = String(character)
                    }
                }
            }
            if index == 1 && character == "#" {
                key += "#"
            }
            if index == 1 && character == "b" {
                key += "b"
            }
        }
        if key != "" {
            if key.count == 1 {
                text.remove(at: text.startIndex)
            }
            if key.count == 2 {
                text.remove(at: text.startIndex)
                text.remove(at: text.startIndex)
            }
        }
        //analyze rest suffix
        if text == "" {
            suffix = "major"
        } else {
            switch text {
            case "major" : suffix = "major"
            case "M" : suffix = "major"
            case "maj" : suffix = "major"
            case "major7" : suffix = "maj7"
            case "M7" : suffix = "maj7"
            case "maj7" : suffix = "maj7"
            case "major7b5" : suffix = "maj7b5"
            case "M7b5" : suffix = "maj7b5"
            case "maj7b5" : suffix = "maj7b5"
            case "major7#5" : suffix = "maj7#5"
            case "M7#5" : suffix = "maj7#5"
            case "maj7#5" : suffix = "maj7#5"
            case "major9" : suffix = "maj9"
            case "M9" : suffix = "maj9"
            case "maj9" : suffix = "maj9"
            case "major11" : suffix = "maj11"
            case "M11" : suffix = "maj11"
            case "maj11" : suffix = "maj11"
            case "major13" : suffix = "maj13"
            case "M13" : suffix = "maj13"
            case "maj13" : suffix = "maj13"
                
            case "minor" : suffix = "minor"
            case "m" : suffix = "minor"
            case "min" : suffix = "minor"
            case "minor6" : suffix = "m6"
            case "m6" : suffix = "m6"
            case "min6" : suffix = "m6"
            case "minor6/9" : suffix = "m6/9"
            case "m6/9" : suffix = "m6/9"
            case "min6/9" : suffix = "m6/9"
            case "minor7" : suffix = "m7"
            case "m7" : suffix = "m7"
            case "min7" : suffix = "m7"
            case "minor7b5" : suffix = "m7b5"
            case "m7b5" : suffix = "m7b5"
            case "min7b5" : suffix = "m7b5"
            case "minor9" : suffix = "m9"
            case "m9" : suffix = "m9"
            case "min9" : suffix = "m9"
            case "minor11" : suffix = "m11"
            case "m11" : suffix = "m11"
            case "min11" : suffix = "m11"
            case "minor add9" : suffix = "madd9"
            case "madd9" : suffix = "madd9"
            case "min add9" : suffix = "madd9"
                
            case "dim" : suffix = "dim"
            case "dim7" : suffix = "dim7"
            case "sus2" : suffix = "sus2"
            case "sus4" : suffix = "sus4"
            case "7sus4" : suffix = "7sus4"
            case "alt" : suffix = "alt"
            case "+" : suffix = "aug"
            case "aug" : suffix = "aug"
            case "+7" : suffix = "aug7"
            case "aug7" : suffix = "aug7"
            case "+9" : suffix = "aug9"
            case "aug9" : suffix = "aug9"
            case "6" : suffix = "6"
            case "6/9" : suffix = "6/9"
            case "7" : suffix = "7"
            case "7b5" : suffix = "7b5"
            case "9" : suffix = "9"
            case "9b5" : suffix = "9b5"
            case "7b9" : suffix = "7b9"
            case "7#9" : suffix = "7#9"
            case "11" : suffix = "11"
            case "9#11" : suffix = "9#11"
            case "13" : suffix = "13"
                
            case "mmaj7" : suffix = "mmaj7"
            case "mmaj7b5" : suffix = "mmaj7b5"
            case "mmaj9" : suffix = "mmaj9"
            case "mmaj11" : suffix = "mmaj11"
                
            case "add9" : suffix = "add9"
                
            case "/E" : suffix = "/E"
            case "/F" : suffix = "/F"
            case "/F#" : suffix = "/F#"
            case "/G" : suffix = "/G"
            case "/G#" : suffix = "/G#"
            case "/A" : suffix = "/A"
            case "/Bb" : suffix = "/Bb"
            case "/B" : suffix = "/B"
            case "/C" : suffix = "/C"
            case "/C#" : suffix = "/C#"
            case "/D" : suffix = "/D"
            case "/D#" : suffix = "/D#"
            case "/Eb" : suffix = "/Eb"
            case "/Db" : suffix = "/Db"
            case "/Gb" : suffix = "/Gb"
            case "/Ab" : suffix = "/Ab"
                
            case "m/E" : suffix = "m/E"
            case "m/F" : suffix = "m/F"
            case "m/F#" : suffix = "m/F#"
            case "m/G" : suffix = "m/G"
            case "m/G#" : suffix = "m/G#"
            case "m/A" : suffix = "m/A"
            case "m/Bb" : suffix = "m/Bb"
            case "m/B" : suffix = "m/B"
            case "m/C" : suffix = "m/C"
            case "m/C#" : suffix = "m/C#"
            case "m/D" : suffix = "m/D"
            case "m/D#" : suffix = "m/D#"
            case "m/Eb" : suffix = "m/Eb"
            case "m/Db" : suffix = "m/Db"
            case "m/Gb" : suffix = "m/Gb"
            case "m/Ab" : suffix = "m/Ab"
                
            default: suffix = ""
            }
        }
        
        return [key, suffix, trueKey, trueSuffix]
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView(song: .constant(Song(text: "Am\nБелый **снег**, серый лед,\n                C\nНа растрескавшейся земле.\n     Dm \nОдеялом лоскутным на ней -\n G\nГород в дорожной петле.\n            Am\nА над городом плывут облака,\n             C\nЗакрывая небесный свет.\n           Dm\nА над городом - желтый дым,\n G\nГороду две тысячи лет,\n Dm\nПрожитых под светом звезды\n      Am\nПо имени солнце...\nd\np\n", isSharp: false)), archive: Archive())
            .environmentObject(Archive())
    }
}
