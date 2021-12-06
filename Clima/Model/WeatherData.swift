//
//  WeatherData.swift
//  Clima
//
//  Created by Isaiah Jenkins on 9/25/21.
//

import Foundation

struct WeatherData: Decodable {
    let list: [List]
}

struct List: Decodable {
    let name: String
    let main: Main
    let weather: [Weather]
}

struct Main: Decodable {
    let temp: Double
}

struct Weather: Decodable {
    let id: Int
    let description: String
}
