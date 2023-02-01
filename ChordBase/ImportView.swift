//
//  ImportView.swift
//  ChordBase
//
//  Created by Lindar Olostur on 15.08.2022.
//

import SwiftUI

struct ImportView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var archive: Archive
    @State var isPicking = false
    @Binding var importIsOpened: Bool
    
    var body: some View {
        VStack {
            Text("Import your own\nsong base")
                .font(.title).bold()
                .multilineTextAlignment(.center)
            Text("You can import your own songs to the app from prepared text file. Put all your songs to any txt file. Use special symbols to mark each song name and artist.\n\n1. Start every new song with author name.\n\n2. Start every author name from a new line. Before an author name insert @ symbol.\n\n3. Start every song name from a new line. Before a song name insert % symbol.").padding()
            Text("***Example:***")
            HStack {
                Text("@Author name\n%Song name\nSong text and chords...")
                Spacer()
            }.padding([.bottom, .horizontal])
            VStack(spacing: 20) {
                Button("Pick a file") {
                    isPicking.toggle()
                }
                .buttonStyle(.borderedProminent)
                .fileImporter(
                    isPresented: $isPicking,
                    allowedContentTypes: [.text],
                    allowsMultipleSelection: false
                ) { result in
                    do {
                        let textFromFile = try String(contentsOf: result.get().first!, encoding: .utf8)
                        print(textFromFile)
                        importSongs(textFromFile: textFromFile)
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    catch {
                        importSongs(textFromFile: "@textFromFile\n%lol \nkek")
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
                //Spacer()
                Button("Back") {
                    importIsOpened.toggle()
                }.padding(.bottom)
            }
        }
    }
    func importSongs(textFromFile: String) {
        var text = textFromFile
        var songWasCreated = false
        text = text.replacingOccurrences(of: "@", with: " @ ")
        text = text.replacingOccurrences(of: "%", with: " % ")
        let parts = text.components(separatedBy: "\n")
        print(parts)
        for line in parts {
            if songWasCreated {
                if !line.contains("@") && !line.contains("%") {
                    archive.myList.songs[0].text += "\n\(line)"
                }
            }
            if line.contains("@") {
                songWasCreated = false
                let author = line.replacingOccurrences(of: "@", with: "")
                archive.myList.songs.insert(Song(author: author.trimmingCharacters(in: .whitespacesAndNewlines)), at: 0)
            }
            if line.contains("%") {
                let name = line.replacingOccurrences(of: "%", with: "")
                archive.myList.songs[0].name = name.trimmingCharacters(in: .whitespacesAndNewlines)
                songWasCreated = true
            }
        }
    }
}

struct ImportView_Previews: PreviewProvider {
    static var previews: some View {
        ImportView(archive: Archive(), importIsOpened: .constant(false)).environmentObject(Archive())
    }
}
