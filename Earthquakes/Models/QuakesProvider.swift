//
//  QuakesProvider.swift
//  Earthquakes-iOS
//
//  Created by Aleksandr on 20.07.2023.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation

@MainActor
class QuakesProvider: ObservableObject {
    
    @Published var quakes: [Quake] = []
    
    private let client: QuakeClient
    
    init(client: QuakeClient = QuakeClient()) {
        self.client = client
    }
    
    func fetch() async throws {
        let quakes = try await client.quakes
        self.quakes = quakes
    }
    
    func delete(atOffsets offsets: IndexSet) {
        quakes.remove(atOffsets: offsets)
    }
}
