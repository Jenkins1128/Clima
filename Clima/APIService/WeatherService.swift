//
//  WeatherService.swift
//  Clima
//
//  Created by Isaiah Jenkins on 1/7/23.
//

import Foundation
import CoreLocation

enum ApiError: Error {
    case emptyDataReceived(String)
    case invalidURL(String)
}

struct Service {
    func performRequest(with urlString: String) async throws -> WeatherModel? {
        do {
            guard let url = URL(string: urlString) else {
                throw ApiError.invalidURL("Invalid url.")
            }

            let (data, _) = try await URLSession.shared.data(from: url)
            
            guard let weather = try parseJSON(data) else {
                return nil
            }
            
            return weather
        } catch {
            return nil
        }
    }
    
    func parseJSON(_ weatherData: Data) throws -> WeatherModel? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            
            guard decodedData.list.count > 0 else {
                throw ApiError.emptyDataReceived("No data received.")
            }
            
            let id = decodedData.list[0].weather[0].id
            let temp = (decodedData.list[0].main.temp * (9 / 5)) + 32.0
            let name = decodedData.list[0].name
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            
            return weather
        } catch {
            return nil
        }
    }
}
