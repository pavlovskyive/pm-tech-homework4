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
        config.timeoutIntervalForRequest = 2
        config.timeoutIntervalForResource = 2
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
        completionHandler: @escaping (Result<T, NetworkError>) -> Void) {

        let request = URLRequest(url: url)

        let task = session.dataTask(with: request) { (data, response, error) in

            DispatchQueue.main.async {
                if error != nil {
                    completionHandler(.failure(NetworkError.noConnection))
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
                    completionHandler(.failure(NetworkError.decodingError))
                }
            }

        }
        task.resume()
    }
}

extension NetworkService {

    public func getCurrentWeather(
        for city: String,
        completionHandler: @escaping (Result<CurrentWeather, NetworkError>) -> Void) {

        guard let url = currentWeatherURL(for: city) else {
            completionHandler(.failure(NetworkError.badUrl))
            return
        }

        getData(by: url, completionHandler: completionHandler)
    }

    public func getCurrentWeather(
        for location: CLLocation,
        completionHandler: @escaping (Result<CurrentWeather, NetworkError>) -> Void) {

        guard let url = currentWeatherURL(for: location) else {
            completionHandler(.failure(NetworkError.badUrl))
            return
        }

        getData(by: url, completionHandler: completionHandler)
    }

    public func getForecast(
        for city: String,
        completionHandler: @escaping (Result<Forecast, NetworkError>) -> Void) {

        guard let url = forecastURL(for: city) else {
            completionHandler(.failure(NetworkError.badUrl))
            return
        }

        getData(by: url, completionHandler: completionHandler)
    }
}

enum NetworkError: String, Error {
    case noConnection = "Your device probably is not connected to the Internet"
    case badUrl = "Error happend while building a request to the server"
    case invalidDataOrResponce = "Server is not responding or responds in an unpredictable way"
    case decodingError = "Could not handle server's data correctly"
    // Maybe implement different status codes handling later.
    case badStatusCode
}
