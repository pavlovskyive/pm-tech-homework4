//
//  NetworkService.swift
//  WeatherApp
//
//  Created by Vsevolod Pavlovskyi on 19.01.2021.
//

import Foundation
import CoreLocation

class NetworkService {
    private let apiKey = myOpenWeatherApiKey
    private let baseURL = "https://api.openweathermap.org/data/2.5"
    private var session: URLSession = {

        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 5
        config.timeoutIntervalForResource = 5
        config.waitsForConnectivity = true
        config.allowsCellularAccess = true

        return URLSession(configuration: config)
    }()

    private func currentWeatherURL(for city: String) -> URL? {
        URL(string: baseURL +
                "/weather" +
                "?q=\(city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" +
                "&units=metric" +
                "&appid=\(myOpenWeatherApiKey)")
    }

    private func currentWeatherURL(for location: CLLocation) -> URL? {
        URL(string: baseURL +
                "/weather" +
                "?lat=\(location.coordinate.latitude)" +
                "&lon=\(location.coordinate.longitude)" +
                "&units=metric" +
                "&appid=\(apiKey)")
    }

    private func forecastURL(for city: String) -> URL? {
        URL(string: baseURL +
                "/forecast" +
                "?q=\(city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" +
                "&units=metric" +
                "&appid=\(apiKey)")
    }
}

extension NetworkService {

    private func getData<T: Decodable>(
        by url: URL,
        completionHandler: @escaping (Result<T, Error>) -> Void) {

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
                        let items = try JSONDecoder().decode(T.self, from: data)
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

    public func getCurrentWeather(
        for city: String,
        completionHandler: @escaping (Result<CurrentWeather, Error>) -> Void) {

        guard let url = currentWeatherURL(for: city) else {
            completionHandler(.failure(NetworkError.badUrl))
            return
        }

        getData(by: url, completionHandler: completionHandler)
    }

    public func getCurrentWeather(
        for location: CLLocation,
        completionHandler: @escaping (Result<CurrentWeather, Error>) -> Void) {

        guard let url = currentWeatherURL(for: location) else {
            completionHandler(.failure(NetworkError.badUrl))
            return
        }

        getData(by: url, completionHandler: completionHandler)
    }

    public func getForecast(
        for city: String,
        completionHandler: @escaping (Result<Forecast, Error>) -> Void) {

        guard let url = forecastURL(for: city) else {
            completionHandler(.failure(NetworkError.badUrl))
            return
        }

        getData(by: url, completionHandler: completionHandler)
    }
}

enum NetworkError: Error {
    case badUrl
    case invalidDataOrResponce
    case badStatusCode
}
