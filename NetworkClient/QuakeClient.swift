//
//  QuakeClient.swift
//  Earthquakes-iOS
//
//  Created by Aleksandr on 20.07.2023.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation

class QuakeClient {
    private static let urlString = "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson"
    
    private let cache: NSCache<NSString, CacheEntryObject> = NSCache()
    
    private let feedURL = URL(string: urlString)!
    
    private lazy var decoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .millisecondsSince1970
        return jsonDecoder
    }()
    
    private let downloader: any HTTPDataDownloader
    
    var quakes: [Quake] {
        get async throws {
            let data = try await downloader.httpData(from: feedURL)
            let geoJSON = try decoder.decode(GeoJSON.self, from: data)
            return geoJSON.quakes
        }
    }
    
    init(downloader: any HTTPDataDownloader = URLSession.shared) {
        self.downloader = downloader
    }
}
