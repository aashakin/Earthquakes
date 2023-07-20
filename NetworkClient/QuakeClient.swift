//
//  QuakeClient.swift
//  Earthquakes-iOS
//
//  Created by Aleksandr on 20.07.2023.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation

actor QuakeClient {
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
    
    func quakeLoaction(from url: URL) async throws -> QuakeLocation {
        if let cached = cache[url] {
            switch cached {
            case .ready(let location):
                return location
            case .inProgress(let task):
                return try await task.value
            }
        }
        
        let task = Task<QuakeLocation, Error> {
            let data = try await downloader.httpData(from: url)
            let location = try decoder.decode(QuakeLocation.self, from: data)
            return location
        }
        
        cache[url] = .inProgress(task)
        
        do {
            let location = try await task.value
            cache[url] = .ready(location)
            return location
        } catch {
            cache[url] = nil
            throw error
        }
    }
}
