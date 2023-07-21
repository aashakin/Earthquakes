//
//  QuakeDetailMap.swift
//  Earthquakes-iOS
//
//  Created by Aleksandr on 21.07.2023.
//  Copyright © 2023 Apple. All rights reserved.
//

import SwiftUI
import MapKit

struct QuakeDetailMap: View {
    @State private var region = MKCoordinateRegion()
    
    private var place: QuakePlace
    
    let location: QuakeLocation
    let tintColor: Color
    
    init(location: QuakeLocation, tintColor: Color) {
        self.location = location
        self.tintColor = tintColor
        self.place = QuakePlace(location: location)
    }
    
    var body: some View {
        Map(coordinateRegion: $region, annotationItems: [place]) { place in
            MapMarker(coordinate: place.location, tint: tintColor)
        }
        .onAppear {
            withAnimation {
                region.center = place.location
                region.span = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
            }
        }
    }
}

struct QuakePlace: Identifiable {
    let id: UUID
    let location: CLLocationCoordinate2D
    
    init(id: UUID = UUID(), location: QuakeLocation) {
        self.id = id
        self.location = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
    }
}
