//
//  BuyMoreOptionsView.swift
//  ChordBase
//
//  Created by Lindar Olostur on 26.08.2022.
//

import SwiftUI

struct BuyMoreOptionsView: View {
    @StateObject var viewModel: ViewModel
    @Binding var buyEditorOpened: Bool
 
    var body: some View {
        VStack {
            Spacer()
            Text("Buy full customization!").font(.title).bold()
            HStack {
//                Button("0.99$ \nfor 1 month") {
//                    viewModel.purchase(lot: "fullEditor")
//                }
//                .buttonStyle(.borderedProminent)
//                .cornerRadius(10)
//                Spacer()
                Button("4.99$ for 6 month") {
                    viewModel.purchase(lot: "fullEditor")
                }
                .buttonStyle(.borderedProminent)
                .cornerRadius(14)
            }//.padding()
            VStack {
                Text("Text customization").font(.title3).bold().padding(10)
                HStack {
                    Text("- Choose your font\n- Choose a color\n- Set interline space\n- Choose apply it to tiles or not").font(.title3)
                    Spacer()
                }.padding(.horizontal)
                Text("Background customization").font(.title3).bold().padding(10)
                HStack {
                    Text("- Choose background color\n- Choose background picture from built-in images\n- Load own image\n- Set image scale\n- Add a blur effect\n- Rotate an image\n\n- Apply customization to all songs\n- Or reset it to defaults").font(.title3)
                    Spacer()
                }.padding(.horizontal)
                Button("Back") {
                    buyEditorOpened.toggle()
                }.padding(.bottom)
            }
        }
    }
}

struct BuyMoreOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        BuyMoreOptionsView(viewModel: ViewModel(), buyEditorOpened: .constant(false))
    }
}
