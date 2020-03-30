//
//  FeatureDetailView.swift
//  Map
//
//  Created by carlos.fonseca on 29/03/2020.
//  Copyright © 2020 carlosefonseca. All rights reserved.
//

import MapCore
import SDWebImageSwiftUI
import SwiftUI


struct FeatureDetailView: View {
    let feature: AppFeature

    var body: some View {
        GeometryReader { geometry in

            VStack(alignment: .leading) {
                HStack {
                    WebImage(url: self.feature.imageUrl)
                        .resizable()
                        .indicator(.activity)
                        .scaledToFit()

                    VStack(alignment: .leading) {
                        Text(self.feature.title ?? "A")
                            .frame(alignment: .leading)
                            .font(.system(.headline))
                            .padding([.top, .bottom])
                        Text(self.feature.subtitle ?? "B")
                            .frame(alignment: .leading)
                            .font(.system(.subheadline))
                    }
                }

                Text(self.feature.description ?? "CC")
                    .multilineTextAlignment(.leading)
                    .font(.system(.body))
            }
            .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
            .frame(width: geometry.size.width)
        }
    }
}

struct FeatureDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let x = AppFeature(title: "01 Arancini de Queijo de Cabra",
                           subtitle: "Um Eléctrico Chamado Tágide",
                           description: "Bolinhas de arroz com queijo de cabra panados e molho de tomate.\n\nDom. a Qui.: 12h-24h | Sex. e Sáb.: 12h-02h\n\nRua da Boavista, 88",
                           imageUrl: URL(string: "https://rotadetapas.com.pt/contents/restaurants/arcodavelha.jpg"),
                           lat: 0, lng: 0)

        return FeatureDetailView(feature: x)
            .previewDevice(PreviewDevice(rawValue: "iPhone 8"))
    }
}
