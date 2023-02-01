//
//  SongView.swift
//  ChordBase
//
//  Created by Lindar Olostur on 28.07.2022.
//

import SwiftUI
import BottomSheet

extension StringProtocol {
    subscript(offset: Int) -> Character {
        self[index(startIndex, offsetBy: offset)]
    }
}

struct Rating: View {
    @Binding var rating: Int
    
    var label = ""

    var maximumRating = 5

    var offImage: Image?
    var onImage = Image(systemName: "star.fill")

    var offColor = Color.gray.opacity(0.3)
    var onColor = Color.yellow
    
    func image(for number: Int) -> Image {
        if number > rating {
            return offImage ?? onImage
        } else {
            return onImage
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            if label.isEmpty == false {
                Text(label)
            }

            ForEach(1..<maximumRating + 1, id: \.self) { number in
                image(for: number)
                    .font(.system(size: UIDevice.isIPhone ? 10 : 15))
                    .foregroundColor(number > rating ? offColor : onColor)
                    .onTapGesture {
                        rating = number
                    }
            }
        }
    }
    
}

struct SongView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: ViewModel
    @Binding var song: Song
    @ObservedObject var archive: Archive
    @FocusState private var fieldIsFocused: Bool
    let allFontNames = UIFont.familyNames
      .flatMap { UIFont.fontNames(forFamilyName: $0) }
    let alignments: [TextAlignment] = [.leading, .center, .trailing]
    @State var isDisabled = false
    @State private var isPlayed = false
    @State private var galeryOpened = false
    @State private var buyEditorOpened = false
    @State private var iPadMenuOpened = true
    @State var bottomSheetPosition: BottomSheetPosition = .dynamicBottom
    @State var bgColor = Color.white
    @State var fnColor = Color.black
    @State private var alertToDefault = false
    @State private var alertApply = false
    @State private var angle = 0.0
    @State private var scale = 1.0
    @State private var blur = 0.0
    var bgColorData = ColorData()
    var fnColorData = ColorData()
    
    init(song: Binding<Song>, archive: Archive, viewModel: StateObject<ViewModel>) {
        _song = song
        self.archive = archive
        _viewModel = viewModel
        UITextView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        HStack {
            VStack {
                VStack {
                    TextField("Enter song name", text: $song.name)
                        .font(song.withTitles ? .custom(song.fontName, size: 35).bold() : .largeTitle.weight(.bold))
                        .minimumScaleFactor(0.5)
                        .foregroundColor(song.withTitles ? fnColor : .black)
                        //.font(.largeTitle.weight(.bold))
                        .multilineTextAlignment(.center)
                        .focused($fieldIsFocused)
                    TextField("Author name", text: $song.author)
                        .font(song.withTitles ? .custom(song.fontName, size: 25) : .system(size: 25, weight: .semibold, design: .rounded))
                        .minimumScaleFactor(0.5)
                        .foregroundColor(song.withTitles ? fnColor : .black)
                        //.font(.system(size: 25, weight: .semibold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .focused($fieldIsFocused)
                }
                TextEditor(text: $song.text)
                    .lineSpacing(song.lineSpace)
                    .font(.custom(song.fontName, size: song.textSize))
                    .foregroundColor(fnColor)
                    .disabled(isDisabled)
                    .disableAutocorrection(true)
                    .padding()
                    .focused($fieldIsFocused)
                    .multilineTextAlignment(alignments[song.textAlignment])
                    .bottomSheet(bottomSheetPosition: self.$bottomSheetPosition, switchablePositions: [
                        .dynamicBottom,
                        //.dynamic
                        .absolute(325)
                    ], headerContent: {
                        if UIDevice.isIPhone {
                            VStack {
                                HStack {
                                    //--LEADER--
                                    VStack {
                                        Stepper("Transpose", onIncrement: {
                                            transposeChord(up: true)
                                        }, onDecrement: {
                                            transposeChord(up: false)
                                        }).labelsHidden()
                                        Text("Transpose")
                                        Button {
                                            song.isSharp.toggle()
                                            if song.isSharp {
                                                changeKeySignature(key: "sharp")
                                            } else {
                                                changeKeySignature(key: "flat")
                                            }
                                        } label: {
                                            //Text(song.isSharp ? "#" : "b")
                                            Text("b/#")
                                                .font(.italic(.body)())
                                                .font(.system(size: 30))
                                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                        }
                                        .padding(.horizontal, 40)
                                        .padding(.vertical, 7)
                                        .background(Color.gray.opacity(0.19))
                                        .cornerRadius(11)
                                    }
                                    Spacer()
                                    //--CENTER--
                                    VStack {
                                        Button {
                                            isPlayed.toggle()
                                        } label: {
                                            Image(systemName: "play")
                                                .font(.system(size: 45))
                                        }
                                        .accessibility(identifier: "PlayInMenu")
                                        .padding()
                                        .foregroundColor(.blue)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.blue, lineWidth: 4)
                                        )
                                        Menu(content: {
                                            ForEach(1...29, id: \.self) { i in
                                                Button {
                                                    song.time = 45 + 15 * i
                                                } label: {
                                                    Text("\(timeConverter(time: 45 + 15 * i))")
                                                }
                                            }
                                        }, label: {
                                            Text("Timer: \(timeConverter(time: song.time))")
                                                .font(.system(size: 16))
                                                .padding(.horizontal, 9)
                                                .padding(.vertical, 7)
                                                .background(Color.gray.opacity(0.19))
                                                .cornerRadius(11)
                                                .padding(.bottom, 9)
                                        })
                                        .padding(.bottom, 2)
                                        .labelsHidden()
                                    }
                                    Spacer()
                                    //--TRAILING--
                                    VStack {
                                        Stepper("Font", onIncrement: {
                                            song.textSize += 1.0
                                        }, onDecrement: {
                                            song.textSize -= 1.0
                                        }).labelsHidden()
                                        Text("Text")
                                        Menu {
                                            Button {
                                                song.textAlignment = 2
                                            } label: {
                                                Label("Right", systemImage: "text.alignright")
                                            }
                                            Button {
                                                song.textAlignment = 1
                                            } label: {
                                                Label("Center", systemImage: "text.aligncenter")
                                            }
                                            Button {
                                                song.textAlignment = 0
                                            } label: {
                                                Label("Left", systemImage: "text.alignleft")
                                            }
                                            
                                        } label: {
                                            Text("Alignment").truncationMode(.middle)
                                                .font(.system(size: 15))
                                                .padding(.horizontal, 9)
                                                .padding(.vertical, 7)
                                                .background(Color.gray.opacity(0.19))
                                                .cornerRadius(11)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.top)
                            }
                        }
                    }
                    ) {
                        if UIDevice.isIPhone {
                            Divider().padding(.vertical, 5)
                            ZStack {
                                ScrollView {
                                    ScrollViewReader { proxy in
                                        HStack {
                                            Text("Text").font(.title2)
                                            Spacer()
                                            Button {
                                                archive.myList.editTextHidden.toggle()
                                                if archive.myList.editTextHidden {
                                                    bottomSheetPosition = .absolute(500)
                                                } else {
                                                    bottomSheetPosition = .absolute(325)
                                                }
                                            } label: {
                                                Image(systemName: archive.myList.editTextHidden ? "chevron.down" : "chevron.right")
                                            }
                                        }
                                        .padding(.horizontal)
                                        if archive.myList.editTextHidden {
                                            //FONT TYPE
                                            HStack {
                                                Text("Choose a font:")
                                                Spacer()
                                                Picker("Choose font", selection: $song.fontName) {
                                                    ForEach(allFontNames, id: \.self) {
                                                        Text($0)//.font(.custom($0, size: 15))
                                                    }
                                                }.pickerStyle(.menu)
                                            }.padding(.horizontal)
                                            //SPACING
                                            HStack {
                                                Text("Spacing")
                                                
                                                Slider(value: $song.lineSpace, in: 0...50)
                                            }.padding(.horizontal)
                                            //BOLD & ITALIC
                                            //                                Toggle("Make Bold", isOn: $song.isBold).padding(.horizontal)
                                            //                                Toggle("Make Italic", isOn: $song.isItalic).padding(.horizontal)
                                            //FONT COLOR
                                            ColorPicker("Choose a font color", selection: $fnColor, supportsOpacity: false)
                                            //.labelsHidden()
                                                .padding(.horizontal)
                                            Toggle("Apply to Titles", isOn: $song.withTitles).padding(.horizontal)
                                        }
                                        Divider()
                                        HStack {
                                            Text("Background").font(.title2)
                                            Spacer()
                                            Button {
                                                archive.myList.editBackHidden.toggle()
                                                if archive.myList.editBackHidden {
                                                    bottomSheetPosition = .absolute(400)
                                                    //proxy.scrollTo(-50, anchor: .bottom)
                                                } else {
                                                    bottomSheetPosition = .absolute(325)
                                                }
                                            } label: {
                                                Image(systemName: archive.myList.editBackHidden ? "chevron.down" : "chevron.right")
                                            }
                                        }
                                        //.id("point")
                                        .padding(.horizontal)
                                        if archive.myList.editBackHidden {
                                            //BACKGROUND COLOR
                                            ColorPicker("Choose a background color", selection: $bgColor, supportsOpacity: false)
                                                .onChange(of: bgColor, perform: { newValue in
                                                    song.bgPic = "bg0"
                                                    song.picFromGallery = ""
                                                })
                                            //.labelsHidden()
                                                .padding(.horizontal)
                                            // BACKGROUND IMAGE
                                            HStack {
                                                Text("Background image:")
                                                Spacer()
                                                Button {
                                                    galeryOpened.toggle()
                                                } label: {
                                                    Text("Choose")
                                                }
                                                .cornerRadius(10)
                                                .buttonStyle(.bordered)
                                            }.padding(.horizontal)
                                            if song.bgPic != "bg0" || song.picFromGallery != "" {
                                                HStack {
                                                    Text("Scale")
                                                    Slider(value: $scale, in: 0.2...2)
                                                }.padding(.horizontal)
                                                HStack {
                                                    Text("Angle")
                                                    Slider(value: $angle, in: 0...360, step: 45)
                                                }.padding(.horizontal)
                                                HStack {
                                                    Text("Blur  ")
                                                    Slider(value: $blur, in: 0...4)
                                                }.padding(.horizontal)
                                            }
                                        }
                                        Divider()
                                        HStack {
                                            Button("Back to Default") {
                                                alertToDefault = true
                                            }
                                            .alert(isPresented: $alertToDefault) {
                                                Alert(title: Text("Back to default?"),
                                                      message: Text("Current customization will back to defaults."),
                                                      primaryButton: .destructive(Text("Yes")) {
                                                    song.fontName = "San Francisco"
                                                    song.withTitles = false
                                                    bgColor = Color.white
                                                    song.picFromGallery = ""
                                                    song.bgPic = "bg0"
                                                    fnColor = Color.black
                                                    song.textSize = 15
                                                    song.lineSpace = 3
                                                }, secondaryButton: .cancel()
                                                )
                                            }
                                            Spacer()
                                            Button("Apply to All") {
                                                alertApply = true
                                            }.alert(isPresented: $alertApply) {
                                                Alert(title: Text("Apply to all songs?"),
                                                      message: Text("Current customization will apply to all songs."),
                                                      primaryButton: .destructive(Text("Yes")) {
                                                    for i in 0..<(archive.myList.songs.count) {
                                                        var item = archive.myList.songs[i]
                                                        item.fontName = song.fontName
                                                        item.withTitles = song.withTitles
                                                        item.bgColor = song.bgColor
                                                        item.fnColor = song.fnColor
                                                        item.bgPic = song.bgPic
                                                        item.lineSpace = song.lineSpace
                                                        archive.myList.songs[i] = item
                                                    }
                                                }, secondaryButton: .cancel()
                                                )
                                            }
                                        }
                                        .padding(.horizontal)
                                        .padding(.bottom, 40)
                                    }
                                }
                                .opacity(viewModel.purchasedIds.contains("fullEditor") ? 1 : 0.2)
                                .disabled(viewModel.purchasedIds.contains("fullEditor") ? false : true)
                                if !viewModel.purchasedIds.contains("fullEditor") {
                                    Button {
                                        buyEditorOpened.toggle()
                                    } label: {
                                        Text("Buy more options")
                                    }
                                    .buttonStyle(.bordered)
                                    .foregroundColor(.white)
                                    .background(Color.blue)
                                    .cornerRadius(20)

                                }
                            }
                        }
                    }
                    .showDragIndicator(UIDevice.isIPhone)
                    .enableContentDrag(false)
                    .showCloseButton(false)
                    .enableSwipeToDismiss(true)
                    .enableTapToDismiss(false)
                
                if UIDevice.isIPad && iPadMenuOpened {
                    HStack {
                        //LEFT
                        ZStack {
                            Form {
                                Section(header: Text("Font")) {
                                    Picker("Font", selection: $song.fontName) {
                                        ForEach(allFontNames, id: \.self) {
                                            Text($0)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    //.padding(.vertical)
                                    Stepper("Spacing", onIncrement: {
                                        song.lineSpace += 1.0
                                    }, onDecrement: {
                                        song.lineSpace -= 1.0
                                    })
                                    //.padding(.vertical)
                                    
                                    ColorPicker("Choose a font color", selection: $fnColor, supportsOpacity: false)
                                        //.padding(.vertical)
                                    Toggle("Apply to Titles", isOn: $song.withTitles)
                                        //.padding(.vertical)
                                }
                            }
                            .padding(.trailing, -10)
                            .disabled(viewModel.purchasedIds.contains("fullEditor") ? false : true)
                            if !viewModel.purchasedIds.contains("fullEditor") {
                                Rectangle().foregroundColor(colorScheme == .dark ? .black : Color("lightgray")).padding(.horizontal, -10)
                                Image(systemName: "multiply.circle")
                                    .foregroundColor(.red)
                                    .font(.system(size: 60))
                                    .opacity(0.3)
                            }
                        }
                        
                        //CENTER
                        Form {
                            Section(header: Text("Base options")) {
                                HStack {
                                    Spacer()
                                    Button {
                                        isPlayed.toggle()
                                    } label: {
                                        Image(systemName: "play")
                                            .font(.system(size: 45))
                                    }
                                    .padding()
                                    .foregroundColor(.blue)
        //                            .overlay(
        //                                Circle()
        //                                    .stroke(Color.blue, lineWidth: 4)
        //                            )
                                    Spacer()
                                }
                                HStack {
                                    Text("Timer")
                                    Spacer()
                                    Picker("Timer", selection: $song.time) {
                                        ForEach(1...29, id: \.self) { i in
                                            Button {
                                                song.time = 45 + 15 * i
                                            } label: {
                                                Text("\(timeConverter(time: 45 + 15 * i))")
                                            }
                                        }
                                    }
                                    //.padding(.vertical)
                                    .pickerStyle(.menu)
                                }
                                Stepper("Transpose", onIncrement: {
                                    transposeChord(up: true)
                                }, onDecrement: {
                                    transposeChord(up: false)
                                })
                                //.padding(.vertical)
                                HStack {
                                    Text("Key Signature")
                                    Spacer()
                                    Button {
                                        song.isSharp.toggle()
                                        if song.isSharp {
                                            changeKeySignature(key: "sharp")
                                        } else {
                                            changeKeySignature(key: "flat")
                                        }
                                    } label: {
                                        Text("   b/#   ")
                                            .font(.italic(.body)())
                                            .font(.system(size: 30))
                                            .foregroundColor(colorScheme == .dark ? .white : .black)
                                    }
                                    .cornerRadius(10)
                                    .buttonStyle(.bordered)
                                }
                                //.padding(.vertical)
                                Stepper("Font Size", onIncrement: {
                                    song.textSize += 1.0
                                }, onDecrement: {
                                    song.textSize -= 1.0
                                })
                                //.padding(.vertical)
                                Picker("Alignment", selection: $song.textAlignment) {
                                    Image(systemName: "text.alignleft").tag(0)
                                    Image(systemName: "text.aligncenter").tag(1)
                                    Image(systemName: "text.alignright").tag(2)
                                }
                                //.padding(.vertical)
                                .pickerStyle(.segmented)
                                if !viewModel.purchasedIds.contains("fullEditor") {
                                    HStack {
                                        Spacer()
                                        Button {
                                            buyEditorOpened.toggle()
                                        } label: {
                                            Text("Buy more options")
                                        }
                                        .buttonStyle(.bordered)
                                        .foregroundColor(.white)
                                        .background(Color.blue)
                                        .cornerRadius(20)
                                        .padding()
                                        Spacer()
                                    }
                                }
                            }
                        }
                        
                        //RIGHT
                        ZStack {
                            Form {
                                Section(header: Text("Background")) {
                                    ColorPicker("Choose a background color", selection: $bgColor, supportsOpacity: false)
                                        .onChange(of: bgColor, perform: { newValue in
                                            song.bgPic = "bg0"
                                            song.picFromGallery = ""
                                        })
                                    HStack {
                                        Text("Image")
                                        Spacer()
                                        Button {
                                            galeryOpened.toggle()
                                        } label: {
                                            Text("Choose")
                                        }
                                        .cornerRadius(10)
                                        .buttonStyle(.bordered)
                                    }
                                    if song.bgPic != "bg0" || song.picFromGallery != "" {
                                        HStack {
                                            Text("Scale")
                                            Slider(value: $scale, in: 0.2...2)
                                        }
                                        HStack {
                                            Text("Angle")
                                            Slider(value: $angle, in: 0...360, step: 45)
                                        }
                                        HStack {
                                            Text("Blur  ")
                                            Slider(value: $blur, in: 0...4)
                                        }
                                    }
                                }
                                Button("Back to Default") {
                                    alertToDefault = true
                                }//.padding(.vertical)
                                .alert(isPresented: $alertToDefault) {
                                    Alert(title: Text("Back to default?"),
                                          message: Text("Current customization will back to defaults."),
                                          primaryButton: .destructive(Text("Yes")) {
                                        song.fontName = "San Francisco"
                                        song.withTitles = false
                                        bgColor = Color.white
                                        song.picFromGallery = ""
                                        song.bgPic = "bg0"
                                        fnColor = Color.black
                                        song.textSize = 15
                                        song.lineSpace = 3
                                    }, secondaryButton: .cancel()
                                    )
                                }
                                Button("Apply to All") {
                                    alertApply = true
                                }//.padding(.vertical)
                                .alert(isPresented: $alertApply) {
                                    Alert(title: Text("Apply to all songs?"),
                                          message: Text("Current customization will apply to all songs."),
                                          primaryButton: .destructive(Text("Yes")) {
                                        for i in 0..<(archive.myList.songs.count) {
                                            var item = archive.myList.songs[i]
                                            item.fontName = song.fontName
                                            item.withTitles = song.withTitles
                                            item.bgColor = song.bgColor
                                            item.fnColor = song.fnColor
                                            item.bgPic = song.bgPic
                                            item.lineSpace = song.lineSpace
                                            archive.myList.songs[i] = item
                                        }
                                    }, secondaryButton: .cancel()
                                    )
                                }
                            }
                            .padding(.leading, -10)
                            .disabled(viewModel.purchasedIds.contains("fullEditor") ? false : true)
                            if !viewModel.purchasedIds.contains("fullEditor") {
                                Rectangle().foregroundColor(colorScheme == .dark ? .black : Color("lightgray")).padding(.horizontal, -10)
                                Image(systemName: "multiply.circle")
                                    .foregroundColor(.red)
                                    .font(.system(size: 60))
                                    .opacity(0.3)
                            }
                        }
                    }
                    .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)))
                }
            }
            .background(archive.getPicToBg(id: song).scaleEffect(scale).blur(radius: blur).rotationEffect(.degrees(angle)))
            
            .background(bgColor)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Button("Hide") {
                        fieldIsFocused = false
                    }
                }
                ToolbarItem() {
                    if bottomSheetPosition == .hidden {
                        Button {
                            bottomSheetPosition = .dynamicBottom
                        } label: {
                            Image(systemName: "play")
                        }
                    }
                    if UIDevice.isIPad {
                        Button {
                            withAnimation {
                                iPadMenuOpened.toggle()
                            }
                        } label: {
                            Image(systemName: iPadMenuOpened ? "menubar.arrow.down.rectangle" : "menubar.arrow.up.rectangle" ).foregroundColor(iPadMenuOpened ? .gray.opacity(0.5) : .blue)
                        }
                    }
                }
                ToolbarItem(placement: .principal) {
                    Menu {
                        Button {
                            song.rate = 0
                        } label: {
                            Text("0")
                        }
                        Button {
                            song.rate = 1
                        } label: {
                            Text("1")
                        }
                        Button {
                            song.rate = 2
                        } label: {
                            Text("2")
                        }
                        Button {
                            song.rate = 3
                        } label: {
                            Text("3")
                        }
                        Button {
                            song.rate = 4
                        } label: {
                            Text("4")
                        }
                        Button {
                            song.rate = 5
                        } label: {
                            Text("5")
                        }
                    } label: {
                        Rating(rating: $song.rate)
                    }
                }
                ToolbarItem(placement: .destructiveAction) {
                    Button {
                        song.isFavorite.toggle()
                    } label: {
                        Image(systemName: song.isFavorite ? "heart.fill" : "heart" )
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationBarTitleDisplayMode(UIDevice.isIPhone ? .inline : .automatic)
            .fullScreenCover(isPresented: $isPlayed) {
                PlayerView(song: $song, archive: archive).statusBar(hidden: true)
            }
            .sheet(isPresented: $galeryOpened) {
                HalfSheet {
                    ImageGaleryView(archive: archive, song: $song).statusBar(hidden: true)
                }
            }
            .sheet(isPresented: $buyEditorOpened, content: {
                BuyMoreOptionsView(viewModel: self.viewModel, buyEditorOpened: $buyEditorOpened)
            })
            .onChange(of: bgColor) { newValue in
                song.bgColor = bgColorData.saveColor(color: newValue)
            }
            .onChange(of: fnColor) { newValue in
                song.fnColor = fnColorData.saveColor(color: newValue)
            }
            .onChange(of: blur) { newValue in
                song.blur = newValue
            }
            .onChange(of: scale) { newValue in
                song.scale = newValue
            }
            .onChange(of: angle) { newValue in
                song.rotation = newValue
            }
            .onAppear() {
                bgColor = bgColorData.loadColor(nums: song.bgColor)
                fnColor = fnColorData.loadColor(nums: song.fnColor)
                blur = song.blur
                scale = song.scale
                angle = song.rotation
            }
//            VStack {
//                if UIDevice.isIPad {
//
//                }
//            }
        }
    }
    
   // ---------------------------------
    
    func timeConverter(time: Int) -> String {
        let minutes = time/60
        let seconds = time%60
        var result = "\(minutes):\(seconds)"
        if result.hasSuffix(":0") {
            result += "0"
        }
        return result
    }
    
    func getKeySignature() -> Bool {
        var isSharp: Bool = true
        isDisabled = true
        song.text = song.text.replacingOccurrences(of: "\t", with: " \t ")
        song.text = song.text.replacingOccurrences(of: "\n", with: " \n ")
        song.text = song.text.replacingOccurrences(of: "\r", with: " \r ")
        song.text = song.text.replacingOccurrences(of: "/", with: " / ")
        song.text = song.text.replacingOccurrences(of: "(", with: " ( ")
        let parts = song.text.components(separatedBy: " ")
        for (_, word) in parts.enumerated() {
            let chord = archive.chordDetection(text: word)
            if chord.hasSuffix("b") {
                isSharp = false
            }
            if chord.hasSuffix("#") {
                isSharp = true
            }
        }
        song.text = parts.joined(separator: " ")
        song.text = song.text.replacingOccurrences(of: " ( ", with: "(")
        song.text = song.text.replacingOccurrences(of: " / ", with: "/")
        song.text = song.text.replacingOccurrences(of: " \r ", with: "\r")
        song.text = song.text.replacingOccurrences(of: " \n ", with: "\n")
        song.text = song.text.replacingOccurrences(of: " \t ", with: "\t")
        isDisabled = false
        return isSharp
    }
    func changeKeySignature(key: String) {
        song.isSharp = getKeySignature()
        isDisabled = true
        song.text = song.text.replacingOccurrences(of: "\t", with: " \t ")
        song.text = song.text.replacingOccurrences(of: "\n", with: " \n ")
        song.text = song.text.replacingOccurrences(of: "\r", with: " \r ")
        song.text = song.text.replacingOccurrences(of: "/", with: " / ")
        song.text = song.text.replacingOccurrences(of: "(", with: " ( ")
        var parts = song.text.components(separatedBy: " ")
        for (index, word) in parts.enumerated() {
            let chord = archive.chordDetection(text: word)
            if chord != "" {
                parts[index] = word.replacingOccurrences(of: chord, with: replaceKey(letter: chord, key: key))
            }
        }
        song.text = parts.joined(separator: " ")
        song.text = song.text.replacingOccurrences(of: " ( ", with: "(")
        song.text = song.text.replacingOccurrences(of: " / ", with: "/")
        song.text = song.text.replacingOccurrences(of: " \r ", with: "\r")
        song.text = song.text.replacingOccurrences(of: " \n ", with: "\n")
        song.text = song.text.replacingOccurrences(of: " \t ", with: "\t")
        isDisabled = false
    }
    func transposeChord(up: Bool) {
        song.isSharp = getKeySignature()
        isDisabled = true
        song.text = song.text.replacingOccurrences(of: "\t", with: " \t ")
        song.text = song.text.replacingOccurrences(of: "\n", with: " \n ")
        song.text = song.text.replacingOccurrences(of: "\r", with: " \r ")
        song.text = song.text.replacingOccurrences(of: "/", with: " / ")
        song.text = song.text.replacingOccurrences(of: "(", with: " ( ")
        var parts = song.text.components(separatedBy: " ")
        for (index, word) in parts.enumerated() {
            let chord = archive.chordDetection(text: word)
            if chord != "" {
                parts[index] = word.replacingOccurrences(of: chord, with: transpose(letter: chord, up: up))
            }
        }
        song.text = parts.joined(separator: " ")
        song.text = song.text.replacingOccurrences(of: " ( ", with: "(")
        song.text = song.text.replacingOccurrences(of: " / ", with: "/")
        song.text = song.text.replacingOccurrences(of: " \r ", with: "\r")
        song.text = song.text.replacingOccurrences(of: " \n ", with: "\n")
        song.text = song.text.replacingOccurrences(of: " \t ", with: "\t")
        isDisabled = false
    }
    
    func transpose(letter: String, up: Bool) -> String {
        var chord = letter
        if chord.hasSuffix("b") {
            song.isSharp = false
        }
        if chord.hasSuffix("#") {
            song.isSharp = true
        }
        if chord.first == "H" {
            chord = chord.replacingOccurrences(of: "H", with: "B")
        }
        let sharpChords = ["A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#"]
        let flatChords = ["A", "Bb", "B", "C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab"]
        var newChordIndex: Int = 0 {
            didSet {
                if newChordIndex == 12 {
                    newChordIndex = 0
                }
                if newChordIndex < 0 {
                    newChordIndex = 11
                }
            }
        }
        var result = ""
        if song.isSharp {
            if let i = sharpChords.firstIndex(where: { $0 == chord }) {
                if up == true {
                    newChordIndex = i + 1
                } else {
                    newChordIndex = i - 1
                }
                result = sharpChords[newChordIndex]
            }
        } else {
            if let i = flatChords.firstIndex(where: { $0 == chord }) {
                if up == true {
                    newChordIndex = i + 1
                } else {
                    newChordIndex = i - 1
                }
                result = flatChords[newChordIndex]
            }
        }
        if result == "" {print("\(chord) don't find output chord. Sharp is \(song.isSharp)")}
        return result
    }
    func replaceKey(letter: String, key: String) -> String {
        var chord = letter
        var keySign = key
        if chord.hasSuffix("b") {
            song.isSharp = false
            keySign = "sharp"
        }
        if chord.hasSuffix("#") {
            song.isSharp = true
            keySign = "flat"
        }
        if chord.first == "H" {
            chord = chord.replacingOccurrences(of: "H", with: "B")
        }
        let sharpChords = ["A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#"]
        let flatChords = ["A", "Bb", "B", "C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab"]
        var newChordIndex: Int = 0
        var result = ""
        if keySign == "flat" {
            if let i = sharpChords.firstIndex(where: { $0 == chord }) {
                newChordIndex = i
                result = flatChords[newChordIndex]
            }
        }
        if keySign == "sharp" {
            if let i = flatChords.firstIndex(where: { $0 == chord }) {
                newChordIndex = i
                result = sharpChords[newChordIndex]
            }
        }
        if result == "" {print("\(chord) don't find output chord. Sharp is \(song.isSharp)")}
        return result
    }
}

//struct SongView_Previews: PreviewProvider {
//    static var previews: some View {
//        SongView(song: .constant(Song(text: "Am\nБелый снег, серый лед,\n                C\nНа растрескавшейся земле.\n     Dm \nОдеялом лоскутным на ней -\n G\nГород в дорожной петле.\n            Am\nА над городом плывут облака,\n             C\nЗакрывая небесный свет.\n           Dm\nА над городом - желтый дым,\n G\nГороду две тысячи лет,\n Dm\nПрожитых под светом звезды\n      Am\nПо имени солнце...\nd\np\n", isSharp: false)), archive: Archive())
//            .environmentObject(Archive())
//    }
//}
