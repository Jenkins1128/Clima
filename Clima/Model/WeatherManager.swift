//
//  WeatherManager.swift
//  Clima
//
//  Created by Isaiah Jenkins on 9/25/21.
//

import Foundation
import CoreLocation

enum ParseError: Error {
    case emptyDataReceived(String)
}

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/find?appid=c19a1961c40679dc75163bc5e61852ce&units=metric"
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String){
        let parsedCityName = cityName.replacingOccurrences(of: " ", with: "%20")
        let urlString = "\(weatherURL)&q=\(parsedCityName)"
        
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                delegate?.didFailWithError(error: error!)
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                guard let weather = try parseJSON(data) else {
                    return
                }
                
                delegate?.didUpdateWeather(self, weather: weather)
            } catch {
                delegate?.didFailWithError(error: error)
                return
            }
        }
        
        task.resume()
    }
    
    func parseJSON(_ weatherData: Data) throws -> WeatherModel? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            
            guard decodedData.list.count > 0 else {
                throw ParseError.emptyDataReceived("No data received.")
            }
            
            let id = decodedData.list[0].weather[0].id
            let temp = (decodedData.list[0].main.temp * (9 / 5)) + 32.0
            let name = decodedData.list[0].name
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            
            return weather
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
