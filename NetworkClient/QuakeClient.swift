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
            var updatedQuakes = geoJSON.quakes
            if let olderThanOneHour = updatedQuakes.firstIndex(where: { $0.time.timeIntervalSinceNow > 3600 }) {
                let indexRange = updatedQuakes.startIndex..<olderThanOneHour
                try await withThrowingTaskGroup(of: (Int, QuakeLocation).self) { group in
                    for index in indexRange {
                        group.addTask {
                            let location = try await self.quakeLocation(from: geoJSON.quakes[index].detail)
                            return (index, location)
                        }
                    }
                    
                    while let result = await group.nextResult() {
                        switch result {
                        case .failure(let error):
                            throw error
                        case .success(let (index, location)):
                            updatedQuakes[index].location = location
                        }
                    }
                }
            }
            return updatedQuakes
        }
    }
    
    init(downloader: any HTTPDataDownloader = URLSession.shared) {
        self.downloader = downloader
    }
    
    func quakeLocation(from url: URL) async throws -> QuakeLocation {
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
