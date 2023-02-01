//
//  ExportView.swift
//  ChordBase
//
//  Created by Lindar Olostur on 31.08.2022.
//

import SwiftUI
import Foundation

struct ExportView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var exportIsOpened: Bool
    @ObservedObject var archive: Archive
    var body: some View {
        VStack {
            Spacer()
            Text("Export your songs")
                .font(.title).bold()
                .multilineTextAlignment(.center)
            Text("You can export your songs from this app to a text file. This file will be store author and song names, lyrics an chords for every song in your base. Later, you will can use this file to upload stored songs in app by manual mode.").padding()
            Spacer()
            VStack(spacing: 20) {
                Button("Export") {
                    exportSongs()
                }
                .buttonStyle(.borderedProminent)
                Button("Back") {
                    exportIsOpened.toggle()
                }.padding(.bottom)
            }
        }
    }
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    func exportSongs() {
        var songsData = ""
        for song in archive.myList.songs {
            let author = "@\(song.author)\n"
            let name = "%\(song.name)\n"
            let lyrics = "\(song.text)\n"
            let full = author + name + lyrics
            songsData += full
        }
        
        let filename = getDocumentsDirectory().appendingPathComponent("exportedSongs.txt")

        do {
            try songsData.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
            self.presentationMode.wrappedValue.dismiss()
        } catch {
            //
        }
    }
    
}

struct ExportView_Previews: PreviewProvider {
    static var previews: some View {
        ExportView(exportIsOpened: .constant(false), archive: Archive()).environmentObject(Archive())
    }
}
