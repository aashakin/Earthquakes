//
//  QuakeDetail.swift
//  Earthquakes-iOS
//
//  Created by Aleksandr on 21.07.2023.
//  Copyright © 2023 Apple. All rights reserved.
//

import SwiftUI

struct QuakeDetail: View {
    @EnvironmentObject private var provider: QuakesProvider
    @State private var location: QuakeLocation? = nil
    
    var quake: Quake
    
    var body: some View {
        VStack {
            if let location = self.location {
                QuakeDetailMap(location: location, tintColor: quake.color)
                    .ignoresSafeArea(.container)
            }
            QuakeMagnitude(quake: quake)
            Text(quake.place)
                .font(.title3)
                .bold()
            Text(quake.time.formatted(date: .long, time: .standard))
                .foregroundStyle(.secondary)
            if let location = self.location {
                Text("Latitude: \(location.latitude.formatted(.number.precision(.fractionLength(3))))")
                Text("Longitude: \(location.longitude.formatted(.number.precision(.fractionLength(3))))")
            }
        }
        .task {
            if self.location == nil {
                if let quakeLocation = quake.location {
                    self.location = quakeLocation
                } else {
                    self.location =  try? await provider.location(for: quake)
                }
            }
        }
    }
}

struct QuakeDetail_Previews: PreviewProvider {
    static var previews: some View {
        QuakeDetail(quake: Quake.preview)
    }
}
