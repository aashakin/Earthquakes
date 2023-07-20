//
//  EarthquakesTests.swift
//  EarthquakesTests
//
//  Created by Aleksandr on 20.07.2023.
//  Copyright © 2023 Apple. All rights reserved.
//

import XCTest
@testable import Earthquakes

final class EarthquakesTests: XCTestCase {

    func test_geoJSONDecoder_decodes_quake() throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        let quake = try decoder.decode(Quake.self, from: testFeature_nc73649170)
        
        XCTAssertEqual(quake.code, "73649170")
        
        let expectedSeconds = TimeInterval(1636129710550) / 1000
        let decodedSeconds = quake.time.timeIntervalSince1970
        
        XCTAssertEqual(decodedSeconds, expectedSeconds, accuracy: 0.00001)
    }
    
    func test_geoJSONDecoder_decodes_geoJSON() throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        let geoJSON = try decoder.decode(GeoJSON.self, from: testQuakesData)
        
        XCTAssertEqual(geoJSON.quakes.count, 6)
        XCTAssertEqual(geoJSON.quakes[0].code, "73649170")
        
        let expectedSeconds = TimeInterval(1636129710550) / 1000
        let decodedSeconds = geoJSON.quakes[0].time.timeIntervalSince1970
        
        XCTAssertEqual(decodedSeconds, expectedSeconds, accuracy: 0.00001)
    }
    
    func test_quakeLocationDecoder_decodes_quakeLocation() throws {
        let decoder = JSONDecoder()
        let decodedLocation = try decoder.decode(QuakeLocation.self, from: testDetail_hv72783692)
        
        XCTAssertEqual(decodedLocation.latitude, 19.2189998626709, accuracy: 0.00000000001)
        XCTAssertEqual(decodedLocation.longitude, -155.434173583984, accuracy: 0.00000000001)
    }
    
    func test_quakeClient_doesFetch_earthquakeData() async throws {
        let downloader = TestDownloader()
        let quakeClient = QuakeClient(downloader: downloader)
        let quakes = try await quakeClient.quakes
        
        XCTAssertEqual(quakes.count, 6)
    }
}
