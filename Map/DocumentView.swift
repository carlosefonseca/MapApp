//
//  DocumentView.swift
//  Map
//
//  Created by carlos.fonseca on 22/03/2020.
//  Copyright © 2020 carlosefonseca. All rights reserved.
//

import SwiftUI
import MapCore


struct DocumentView: View {
    var document: Document
    var dismiss: () -> Void
    var onSelect: (AppFeature) -> Void



    var body: some View {
        VStack {
            HStack {
                Text("File Name") .foregroundColor(.secondary)

                Text(document.fileURL.lastPathComponent)
                Button("Done", action: dismiss)
            }
            MapView(onSelect: onSelect).edgesIgnoringSafeArea(.all)

        }
    }
}
