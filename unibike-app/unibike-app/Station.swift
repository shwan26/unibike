//
//  Station.swift
//  unibike-app
//
//  Created by Giyu Tomioka on 9/21/24.
//


import Foundation

struct Station: Codable {
    let name: String
    let latitude: Double
    let longitude: Double
    let bike: Int
    
}

func loadStationsFromJSON() -> [Station]? {
    if let path = Bundle.main.path(forResource: "stations", ofType: "json") {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let stations = try JSONDecoder().decode([Station].self, from: data)
            return stations
        } catch {
            print("Error loading JSON: \(error)")
        }
    }
    return nil
}
