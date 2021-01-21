//
//  Weather.swift
//  WeatherApp
//
//  Created by Vsevolod Pavlovskyi on 20.01.2021.
//

import Foundation

struct CurrentWeather: Codable {

    let weather: [Weather]
    let main: CurrentWeatherMain
    let city: String

    enum CodingKeys: String, CodingKey {
        case weather
        case main
        case city = "name"
    }
}

extension CurrentWeather: Reorderable {
    typealias OrderElement = String
    var orderElement: OrderElement { city }
}

struct Weather: Codable {
    let identifier: Int
    let main: String
    let description: String

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case main
        case description
    }
}

struct CurrentWeatherMain: Codable {
    let temperature: Double

    enum CodingKeys: String, CodingKey {
        case temperature = "temp"
    }
}

struct Daily: Codable {
    let dataTime: Int
    let sunrise: Int
    let sunset: Int
    let temp: Temperature
    let feelsLike: FeelsLike
    let pressure: Int
    let humidity: Int
    let dewPoint: Double
    let windSpeed: Double
    let windDegree: Int
    let weather: [Weather]
    let clouds: Int
    let uvi: Double
}

extension Daily {

    enum CodingKeys: String, CodingKey {
        case dataTime = "dt"
        case sunrise
        case sunset
        case temp
        case feelsLike = "feels_like"
        case pressure
        case humidity
        case dewPoint = "dew_point"
        case windSpeed = "wind_speed"
        case windDegree = "wind_deg"
        case weather
        case clouds
        case uvi
    }
}

struct Temperature: Codable {
    let day: Double
    let min: Double
    let max: Double
    let night: Double
    let eve: Double
    let morn: Double
}

struct FeelsLike: Codable {
    let day: Double
    let night: Double
    let eve: Double
    let morn: Double
}
