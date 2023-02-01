//
//  SongListView.swift
//  ChordBase
//
//  Created by Lindar Olostur on 28.07.2022.
//

import SwiftUI

struct SongListView: View {
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var archive: Archive
    @StateObject var viewModel = ViewModel()
    @State private var openeSongView = false
    @FocusState private var fieldIsFocused: Bool
    @State private var showFavoritesOnly = false
    @State private var searchTerm: String = ""
    @State private var exportIsOpened = false
    @State private var importIsOpened = false
    @State private var browserIsOpened = false
    @State private var sortingAZ = false
    @State private var sortingRating = false
    var searchResult: [Song] {
        if searchTerm.isEmpty {
            return archive.myList.songs
        } else {
            return archive.myList.songs.filter { $0.name.localizedCaseInsensitiveContains(searchTerm) || $0.author.localizedCaseInsensitiveContains(searchTerm)}
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    if showFavoritesOnly {
                        ForEach(searchResult, id: \.id) { song in
                            if song.isFavorite == true {
                                NavigationLink(destination: SongView(
                                    song: $archive.myList.songs[archive.myList.songs.firstIndex(of: song) ?? 0],
                                    archive: self.archive, viewModel: _viewModel)
                                ) {
                                    HStack {
                                        Text(
                                            song.author == "" && song.name == "" ? "New song" : "\(song.author) - \(song.name)"
                                        )
                                        Spacer()
                                        Image(systemName: song.isFavorite ? "heart.fill" : "" ).foregroundColor(.red)
                                    }
                                }
                            }
                       }.onDelete { (indexSet) in
                           archive.myList.songs.remove(atOffsets: indexSet)
                       }
                    } else {
                        ForEach(searchResult, id: \.id) { song in
                            NavigationLink(destination: SongView(
                                song: $archive.myList.songs[archive.myList.songs.firstIndex(of: song) ?? 0],
                                archive: self.archive, viewModel: _viewModel)
                            ) {
                                HStack {
                                    Text(
                                        song.author == "" && song.name == "" ? "New song" : "\(song.author) - \(song.name)"
                                    )
                                    Spacer()
                                    Image(systemName: song.isFavorite ? "heart.fill" : "" ).foregroundColor(.red)
                                }
                            }
                        }.onDelete { (indexSet) in
                           archive.myList.songs.remove(atOffsets: indexSet)
                       }
                    }
                }
                .navigationTitle("My Songs")
                .navigationBarBackButtonHidden(true)
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Button("Hide") {
                        fieldIsFocused = false
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        archive.myList.songs.append(Song())
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    if viewModel.purchasedIds.sorted(by: <) != ["buyMeCoffee", "buyMeDrink", "buyMePizza"] {
                        Menu {
                            if !viewModel.purchasedIds.contains("buyMeCoffee") {
                                Button {
                                    viewModel.purchase(lot: "buyMeCoffee")
                                } label: {
                                    Label("Buy me a coffe", systemImage: "cup.and.saucer")
                                }
                            }
                            if !viewModel.purchasedIds.contains("buyMePizza") {
                                Button {
                                    viewModel.purchase(lot: "buyMePizza")
                                } label: {
                                    Label {
                                        Text("Buy me a pizza")
                                    } icon: {
                                        Image("pizza")
                                    }
                                }
                            }
                            if !viewModel.purchasedIds.contains("buyMeDrink") {
                                Button {
                                    viewModel.purchase(lot: "buyMeDrink")
                                } label: {
                                    Label {
                                        Text("Buy me a drink")
                                    } icon: {
                                        Image("bottle")
                                    }
                                }
                            }
                        } label: {
                            Image(systemName: "dollarsign.circle.fill")
                                .opacity(0.7)
                                .foregroundColor(colorScheme == .dark ? .yellow : .orange)
    //                            .foregroundColor(
    //                            viewModel.purchasedIds.isEmpty ? (colorScheme == .dark ? .yellow : .orange) : (colorScheme == .dark ? .gray : .gray))
                        }
                    }
                }
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button {
//                        //
//                    } label: {
//                        Image(systemName: "square.and.arrow.down")
//                    }
//                }
                ToolbarItem() {
                    Button {
                        browserIsOpened.toggle()
                    } label: {
                        Image(systemName: "network")
                    }
                }
                ToolbarItem(placement: .destructiveAction) {
                    Menu {
//                        Button {
//                            archive.myList.songs.sort {
//                                $0.author > $1.author
//                            }
//                        } label: {
//                            Label("Buy full version", systemImage: "dollarsign.circle")
//                        }
                        Toggle(isOn: $showFavoritesOnly) {
                            Label("Show Favorites", systemImage: "heart")
                        }
                        Button {
                            if sortingAZ {
                                archive.myList.songs.sort {
                                    $0.author > $1.author
                                }
                                sortingAZ = false
                            } else {
                                archive.myList.songs.sort {
                                    $0.author < $1.author
                                }
                                sortingAZ = true
                            }
                        } label: {
#if targetEnvironment(macCatalyst)
                            Label("Sorting alphabet", systemImage: "abc")
#else
                            Label("Sorting", systemImage: "abc")
#endif
                        }
                        Button {
                            if sortingRating {
                                archive.myList.songs.sort {
                                    $0.rate > $1.rate
                                }
                                sortingRating = false
                            } else {
                                archive.myList.songs.sort {
                                    $0.rate < $1.rate
                                }
                                sortingRating = true
                            }
                        } label: {
#if targetEnvironment(macCatalyst)
                            Label("Sorting by rating", systemImage: "abc")
#else
                            Label("Sorting", systemImage: "star")
#endif
                        }
                        Section {
                            Button {
                                importIsOpened.toggle()
                            } label: {
                                Text("Import")
                            }
                            Button {
                                exportIsOpened.toggle()
                            } label: {
                                Text("Export")
                            }
//                            Button {
//                                //synchronize()
//                            } label: {
//                                Text("Synchronize")
//                            }
                        }
//                        Section {
//                            Button {
//                                archive.myList.isDarkMode.toggle()
//                            } label: {
//                                if colorScheme == .dark {
//                                    Label("Day mode", systemImage: "sun.max.fill")
//                                } else {
//                                    Label("Night mode", systemImage: "moon")
//                                }
//                            }
//                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease")
                    }
                }
            }
        }
        .preferredColorScheme(archive.myList.isDarkMode ? .dark : .light)
        .searchable(text: $searchTerm)
        .onAppear {
            viewModel.fetchProducts()
            if UserDefaults.standard.value(forKey: "isNotFirstLaunch") == nil {
                archive.getFile()
                UserDefaults.standard.set(true, forKey: "isNotFirstLaunch")
                archive.writeToFile()
            } else {
                //archive.myList = archive.autoload()
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                archive.myList = archive.autoload()
            }
            else if newPhase == .inactive {
                archive.writeToFile()
            }
            else if newPhase == .background {
                archive.writeToFile()
            }
        }
        .sheet(isPresented: $exportIsOpened) {
            ExportView(exportIsOpened: $exportIsOpened, archive: self.archive).statusBar(hidden: true)
        }
        .sheet(isPresented: $importIsOpened) {
            ImportView(archive: self.archive, importIsOpened: $importIsOpened).statusBar(hidden: true)
        }
        .sheet(isPresented: $browserIsOpened) {
            SearchView(browserIsOpened: $browserIsOpened, archive: self.archive).statusBar(hidden: true)
        }
    }
}

struct SongListView_Previews: PreviewProvider {
    static var previews: some View {
        SongListView().environmentObject(Archive())
    }
}
