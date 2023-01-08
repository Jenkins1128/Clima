//
//  WeatherManager.swift
//  Clima
//
//  Created by Isaiah Jenkins on 9/25/21.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    var delegate: WeatherManagerDelegate?
    var service = Service()
    
    let weatherURL = "https://api.openweathermap.org/data/2.5/find?appid=c19a1961c40679dc75163bc5e61852ce&units=metric"
    
    func fetchWeather(cityName: String) {
        let parsedCityName = cityName.replacingOccurrences(of: " ", with: "%20")
        let urlString = "\(weatherURL)&q=\(parsedCityName)"

        Task {
            do {
                guard let results = try await service.performRequest(with: urlString) else {
                    return
                }
                
                delegate?.didUpdateWeather(weather: results)
            } catch {
                delegate?.didFailWithError(error: error)
            }
        }
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        
        Task {
            do {
                guard let results = try await service.performRequest(with: urlString) else {
                    return
                }
                
                delegate?.didUpdateWeather(weather: results)
            } catch {
                delegate?.didFailWithError(error: error)
            }
        }
    }
}
