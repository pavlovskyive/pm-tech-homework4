//
//  StorageService.swift
//  WeatherApp
//
//  Created by Vsevolod Pavlovskyi on 23.01.2021.
//

import Foundation

protocol StorageService {
    func getCities() -> [String]
    func setCities(cities: [String])
}

class DefaultsStorage: StorageService {

    private let defaults = UserDefaults.standard

    func getCities() -> [String] {
        defaults.object(forKey: "Cities") as? [String] ?? ["Kyiv", "Dnipro"]
    }

    func setCities(cities: [String]) {
        defaults.set(cities, forKey: "Cities")
    }
}
