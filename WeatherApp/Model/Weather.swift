//
//  Weather.swift
//  WeatherApp
//
//  Created by Vsevolod Pavlovskyi on 20.01.2021.
//

import Foundation

struct CurrentWeather: Codable {

    let dateTime: Int
    let weather: [Weather]
    let main: CurrentWeatherMain
    let city: String

    enum CodingKeys: String, CodingKey {
        case dateTime = "dt"
        case weather
        case main
        case city = "name"
    }
}

extension CurrentWeather: Reorderable {
    typealias OrderElement = String
    var orderElement: OrderElement { city }
}

struct Forecast: Codable {
    var list: [Hourly]

    func grouped() -> [Date: [Hourly]] {
        let empty: [Date: [Hourly]] = [:]

        return list.reduce(into: empty) { acc, cur in
            let curDate = Date(timeIntervalSince1970: cur.dateTime)
            let components = Calendar.current.dateComponents([.year, .month, .day], from: curDate)
            let date = Calendar.current.date(from: components)!
            let existing = acc[date] ?? []
            acc[date] = existing + [cur]
        }
    }
}

struct Hourly: Codable {
    let dateTime: Double
    let weather: [Weather]
    let main: CurrentWeatherMain

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        dateTime = try values.decode(Double.self, forKey: .dateTime)
        weather = try values.decode([Weather].self, forKey: .weather)
        main = try values.decode(CurrentWeatherMain.self, forKey: .main)
    }

    enum CodingKeys: String, CodingKey {
        case dateTime = "dt"
        case weather
        case main
    }
}

struct Weather: Codable {
    let identifier: Int
    let main: String
    let description: String
    let icon: String

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case main
        case description
        case icon
    }
}

struct CurrentWeatherMain: Codable {
    let temperature: Double

    enum CodingKeys: String, CodingKey {
        case temperature = "temp"
    }
}
