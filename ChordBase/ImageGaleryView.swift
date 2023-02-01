//
//  ImageGaleryView.swift
//  ChordBase
//
//  Created by Lindar Olostur on 23.08.2022.
//

import SwiftUI
import ImagePickerSwiftUI

extension UIImage {
    func toPngString() -> String? {
        let data = self.pngData()
        return data?.base64EncodedString(options: .endLineWithLineFeed)
    }
  
    func toJpegString(compressionQuality cq: CGFloat) -> String? {
        let data = self.jpegData(compressionQuality: cq)
        return data?.base64EncodedString(options: .endLineWithLineFeed)
    }
}

extension String {
    func toImage() -> UIImage? {
        if let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters){
            return UIImage(data: data)
        }
        return nil
    }
}

class HalfSheetController<Content>: UIHostingController<Content> where Content : View {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let presentation = sheetPresentationController {
            presentation.detents = [.medium()]//, .large()]
            presentation.prefersGrabberVisible = true
//            presentation.largestUndimmedDetentIdentifier = .medium
        }
    }
}

struct HalfSheet<Content>: UIViewControllerRepresentable where Content : View {

    private let content: Content
    
    @inlinable init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    func makeUIViewController(context: Context) -> HalfSheetController<Content> {
        return HalfSheetController(rootView: content)
    }
    
    func updateUIViewController(_: HalfSheetController<Content>, context: Context) {
    }
}

struct ImageGaleryView: View {
    @ObservedObject var archive: Archive
    @Binding var song: Song
    @State var selectedImage: UIImage?
    @State var showPicker: Bool = false
    let data = (0...30).map { "bg\($0)" }
    let columns = [
        GridItem(.fixed(UIDevice.isIPad ? 150 : 100)),
            GridItem(.flexible()),
            GridItem(.flexible()),
    ]
    @State private var cellSize: CGFloat = 150
    var body: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: columns, spacing: UIDevice.isIPad ? 10 : 15) {
                ForEach(data, id: \.self) { item in
                    Button {
                        song.bgPic = item
                    } label: {
                        Image(item)
                            .scaleEffect(0.4)
                            .frame(width: cellSize, height: cellSize)
                            .background(Color.red.opacity(0))
                            .clipShape(Rectangle())
                            .shadow(radius: 10)
                            .overlay(Rectangle().stroke(Color.gray, lineWidth: 2).opacity(0.1))
                    }
                }
                Button {
                    showPicker.toggle()
                } label: {
                    Image(systemName: "plus")
                        .font(.largeTitle)
                        .frame(width: cellSize, height: cellSize)
                        .background(Color.red.opacity(0))
                        .clipShape(Rectangle())
                        .shadow(radius: 10)
                        .overlay(Rectangle().stroke(Color.gray, lineWidth: 2).opacity(0.1))
                }
            }.padding(.vertical)
            .padding(.horizontal)
        }
        .sheet(isPresented: $showPicker) {
            ImagePickerSwiftUI(
              selectedImage: $selectedImage,
              sourceType: .photoLibrary, allowsEditing: false
            )
            .onDisappear() {
                if selectedImage != nil {
                    song.bgPic = "bg0"
                    song.picFromGallery = (selectedImage!.toJpegString(compressionQuality: 100)!)
                }
            }
            .onAppear() {
                if UIDevice.isIPad {
                    cellSize = 150
                } else {
                    cellSize = 100
                }
            }
          }
    }
}

struct ImageGaleryView_Previews: PreviewProvider {
    static var previews: some View {
        ImageGaleryView(archive: Archive(), song: .constant(Song()))
            .environmentObject(Archive())
    }
}
