//
//  WeatherData.swift
//  Weather App
//
//  Created by Nuha Alharbi on 20/02/2023.
//

import Foundation

struct WeatherData : Codable {
    let current : Current?
    let hourly : [Hourly]?
    let daily : [Daily]?
}

struct Current : Codable {
    let dt : Int?
    let windSpeed : Double?
    let temp : Double?
    let feelsLike : Double?
    let humidity : Int?
    let clouds : Int?
    let weather : [Weather]?
    
    enum CodingKeys: String, CodingKey {
        case dt, temp , humidity, clouds, weather
        case feelsLike = "feels_like"
        case windSpeed = "wind_speed"
    }
}

struct Hourly : Codable {
    let dt : Int?
    let temp : Double?
}

struct Daily : Codable {
    let dt : Int?
    let temp : Temperature?
    let weather : [Weather]?
    let pop : Double?
}

struct Temperature : Codable {
    let min : Double?
    let max : Double?
}

struct Weather : Codable {
    let description : String?
    let icon : String?
}
