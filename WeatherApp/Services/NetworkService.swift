//
//  NetworkService.swift
//  WeatherApp
//
//  Created by Vsevolod Pavlovskyi on 19.01.2021.
//

import Foundation
import CoreLocation

class NetworkService {
    static let shared = NetworkService()

    private let apiKey = myOpenWeatherApiKey
    private let baseUrl = "https://api.openweathermap.org/data/2.5/weather"
    private var session: URLSession = {

        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 5
        config.timeoutIntervalForResource = 5
        config.waitsForConnectivity = true
        config.allowsCellularAccess = true
        return URLSession(configuration: config)
    }()

    func currentWeatherURL(for city: String) -> URL? {
        URL(string: baseUrl +
                "?q=\(city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" +
                "&units=metric" +
                "&appid=\(myOpenWeatherApiKey)")
    }

    func currentWeatherURL(for location: CLLocation) -> URL? {
        URL(string: baseUrl +
                "?lat=\(location.coordinate.latitude)" +
                "&lon=\(location.coordinate.longitude)" +
                "&units=metric" +
                "&appid=\(apiKey)")
    }
}

extension NetworkService {
    private func getCurrentWeather(
        by url: URL,
        completionHandler: @escaping (Result<CurrentWeather, Error>) -> Void) {

        let request = URLRequest(url: url)

        let task = session.dataTask(with: request) { (data, response, error) in

            DispatchQueue.main.async {
                if let error = error {
                    completionHandler(.failure(error))
                    return
                }

                guard let data = data, let response = response as? HTTPURLResponse else {
                    completionHandler(.failure(NetworkError.invalidDataOrResponce))
                    return
                }

                do {
                    if response.statusCode == 200 {
                        let items = try JSONDecoder().decode(CurrentWeather.self, from: data)
                        completionHandler(.success(items))
                    } else {
                        completionHandler(.failure(NetworkError.badStatusCode))
                    }
                } catch {
                    completionHandler(.failure(error))
                }
            }

        }
        task.resume()
    }
}

extension NetworkService {

    func getCurrentWeather(
        for city: String,
        completionHandler: @escaping (Result<CurrentWeather, Error>) -> Void) {

        guard let url = currentWeatherURL(for: city) else {
            completionHandler(.failure(NetworkError.badUrl))
            return
        }

        getCurrentWeather(by: url, completionHandler: completionHandler)
    }

    public func getCurrentWeather(
        for location: CLLocation,
        completionHandler: @escaping (Result<CurrentWeather, Error>) -> Void) {

        guard let url = currentWeatherURL(for: location) else {
            completionHandler(.failure(NetworkError.badUrl))
            return
        }

        getCurrentWeather(by: url, completionHandler: completionHandler)
    }
}

enum NetworkError: Error {
    case badUrl
    case invalidDataOrResponce
    case badStatusCode
}
