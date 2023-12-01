//
//  WeatherService.swift
//  WeatherAPI
//
//  Created by Luis Augusto Silva on 1/12/23.
//

import Foundation

struct WeatherResponse: Decodable {
    var latitude: Float
    var longitude: Float
    var generationtime_ms: Double
    var utc_offset_seconds: Int
    var timezone: String
    var timezone_abbreviation: String
    var elevation: Double
    var hourly: HourlyData
}

struct HourlyData: Decodable {
    var time: [String]
    var temperature_2m: [Double]
}

struct HourlyForecast: Identifiable {
    let id = UUID()
    let time: String
    let temperature: Double
    var latitude: Float
    var longitude: Float
    
    // Formatear la hora para ser mostrada
    var formattedTime: String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Ajustar según zona horaria

            if let date = dateFormatter.date(from: time) {
                dateFormatter.dateFormat = "dd-MM HH:mm" // Formato de hora deseado
                return dateFormatter.string(from: date)
            }
            return time
    }
}


// Servicio de clima que interactúa con la API de Open-Meteo.
class WeatherService {
    func fetchWeatherData(latitude: Double, longitude: Double, completion: @escaping (Result<[HourlyForecast], Error>) -> Void) {
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&hourly=temperature_2m&format=json"
        print(urlString)
        guard let url = URL(string: urlString) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            //print(data, response.data, error)
            if let error = error {
                print(error)
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(URLError(.cannotParseResponse)))
                return
            }
            
    
            do {
                let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
                let forecasts = zip(weatherResponse.hourly.time, weatherResponse.hourly.temperature_2m)
                    .map { HourlyForecast(time: $0.0, temperature: $0.1, latitude: weatherResponse.latitude, longitude: weatherResponse.longitude) }
                completion(.success(forecasts))
            } catch {
                print(error)
                completion(.failure(error))
            }
        }.resume()
    }
}
