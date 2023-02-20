//
//  WeatherModal.swift
//  Weather App
//
//  Created by Nuha Alharbi on 20/02/2023.
//

import Foundation

struct WeatherModal {
    let description: String
    let currentTemp: Double
    let highTemp: Double
    let lowTemp: Double
    let daily : [DailyWeatherModal]
    let hourly: [HourlyWeatherModal]
}
