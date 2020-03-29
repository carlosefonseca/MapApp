//
//  DocumentView.swift
//  Map
//
//  Created by carlos.fonseca on 22/03/2020.
//  Copyright © 2020 carlosefonseca. All rights reserved.
//

import MapCore
import SwiftUI

struct DocumentView: View {
    var document: Document
    @EnvironmentObject var viewState: ViewState
    
    var dismiss: () -> Void
    var onSelect: (AppFeature) -> Void

    @State private var showingAlert = false
    @State private var camera = MapView.Camera.all

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                Button("Done", action: dismiss).padding(.leading)
                Button(action: { self.showingAlert = true }) { Image(systemName: "gear") }
                    .padding([.leading, .trailing])
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text("Important message"), message: Text("Wear sunscreen"), dismissButton: .default(Text("Got it!")))
                    }
                Spacer()
                Text("File Name").foregroundColor(.secondary)
                Text(document.fileURL.lastPathComponent)
                Spacer()
                if (self.viewState.camera != .all) {
                    Button(action: { self.viewState.camera = .all }) { Image(systemName: "minus.magnifyingglass") }.padding(.trailing)
                }
            }.frame(height: 40, alignment: Alignment.center)

            MapView(onSelect: onSelect).edgesIgnoringSafeArea(.all)
        }
    }
}
