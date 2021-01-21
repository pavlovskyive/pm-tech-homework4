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
    private var session = URLSession.shared

    func currentWeatherURL(for city: String) -> URL? {
        URL(string: baseUrl +
                "?q=\(city)" +
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
                        print(String(data: data, encoding: .utf8)!)
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

    func getCurrentWeather(
        for cities: [String],
        completionHandler: @escaping (Result<[CurrentWeather], Error>) -> Void) {

        var fetchedData = [CurrentWeather]()

        let group = DispatchGroup()

        cities.forEach { city in

            group.enter()

            NetworkService.shared.getCurrentWeather(for: city) { result in
                switch result {
                case .success(let weather):
                    fetchedData.append(weather)
                case .failure(let error):
                    print(error)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            return completionHandler(
                .success(fetchedData.reorder(by: cities)))
        }

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
