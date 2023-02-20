//
//  WeatherManager.swift
//  Weather App
//
//  Created by Nuha Alharbi on 20/02/2023.
//

import Foundation

protocol WeatherMangerDelegate {
    func didUpdateWeather(_ manager: WeatherManger, weatherModal: WeatherModal)
    func didFailError(error: Error)
}

struct WeatherManger {
    
    let apiKey = "YOUR-KEY"
    let weatherURLString = "https://api.openweathermap.org/data/3.0/onecall?lat=21.3891&lon=39.8579&units=metric"
    let formatter = DateFormatter()
    var delegate: WeatherMangerDelegate?
    
    func featchWeatherData(latitude lan: String, longitude lon: String) {
        let urlString = "\(weatherURLString)&lat=\(lan)&lon=\(lon)&appid=\(apiKey)"
        performURLRequest(urlString)
    }
    
    func performURLRequest(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { data , response, error in
            if error != nil {
                print(error)
            }
            
            if let safeData = data {
                if let weatherModal = parseJSON(safeData){
                    delegate?.didUpdateWeather(self, weatherModal: weatherModal)
                }
            }
        }
        task.resume()
    }
    
    func parseJSON(_ data: Data) -> WeatherModal? {
        let decoder = JSONDecoder()
        do {
            let weatherData = try decoder.decode(WeatherData.self, from: data)
            
            formatter.timeStyle = .short
            formatter.dateFormat = "EEEE"
            let currentTemp = weatherData.current?.temp ?? 0
            let highTemp = weatherData.daily?[0].temp?.max ?? 0
            let lowTemp = weatherData.daily?[0].temp?.min ?? 0
            let des = weatherData.current?.weather?[0].description ?? "Unknown"
            var daily = [DailyWeatherModal]()
            var hourly = [HourlyWeatherModal]()
            
            for dailyWeather in weatherData.daily ?? [] {
                let day = formatter.string(from: Date(timeIntervalSince1970: TimeInterval(dailyWeather.dt ?? 0)))
                let des = dailyWeather.weather?[0].description ?? "Unknown"
                let hTemp = String(Int(dailyWeather.temp?.max ?? 0))
                let lTemp = String(Int(dailyWeather.temp?.min ?? 0))
                let iconURL = URL(string:"http://openweathermap.org/img/wn/\(dailyWeather.weather?[0].icon ?? "01d")@2x.png")!
                
                let dailyModal = DailyWeatherModal(day: day, description: des, iconURL: iconURL, highTemp: hTemp, lowTemp: lTemp)
                daily.append(dailyModal)
            }
            
            formatter.dateFormat = "h a"
            for hourlyWeather in weatherData.hourly ?? [] {
                let time = formatter.string(from: Date(timeIntervalSince1970: TimeInterval(hourlyWeather.dt ?? 0)))
                let temp = String(Int(hourlyWeather.temp ?? 0))
                
                let hourlyModal = HourlyWeatherModal(time: time, tempretuare: temp)
                hourly.append(hourlyModal)
            }
            
            let weatherModal = WeatherModal(description: des, currentTemp: currentTemp, highTemp: highTemp, lowTemp: lowTemp, daily: daily, hourly: hourly)
            
            return weatherModal
        } catch {
            delegate?.didFailError(error: error)
            return nil
        }
        
    }
}
