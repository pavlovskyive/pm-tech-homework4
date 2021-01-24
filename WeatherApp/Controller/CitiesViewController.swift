//
//  CitiesViewController.swift
//  WeatherApp
//
//  Created by Vsevolod Pavlovskyi on 19.01.2021.
//

import UIKit
import CoreLocation

class CitiesViewController: UIViewController {

    // MARK: - Variables

    var networkService = NetworkService()
    let locationManager = CLLocationManager()
    lazy var storageService: StorageService = DefaultsStorage()

    enum Section: String, CaseIterable {
        case location = "Weather by location"
        case cities = "Weather in added cities"
    }

    var sections: [Section] = [.cities]

    var weatherData = [Section: [CurrentWeather]]()

    // Sample location data.
    var location: CLLocation?

    // Collection View.
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()

        layout.sectionInset = UIEdgeInsets(
            top: 10, left: 0, bottom: 10, right: 0)

        layout.itemSize = CGSize(width: view.bounds.width  - 30, height: 90)
        layout.headerReferenceSize = CGSize(width: view.bounds.width - 30, height: 40)

        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    lazy var refreshControl = UIRefreshControl()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupLocation()
        setupCollectionView()
    }

    // MARK: - Methods

    @objc private func getData() {

        // Delete old data.
        weatherData[.location] = nil
        weatherData[.cities] = []

        // Create Dispatch Group.
        let group = DispatchGroup()

        // First async -- Getting weather info of current location.
        if let location = location {
            group.enter()
            networkService.getCurrentWeather(for: location) { [weak self] result in
                switch result {
                case .success(let data):
                    self?.weatherData[.location] = [data]
                case .failure:
                    break
                }

                // Decrease count.
                group.leave()
            }
        }

        // It was decided to get each city weather separately.
        //
        // Why: If error occures, it should be handled here, not in Network Service.
        // Because of that completion is called on error,
        // and DispathGroup count inside Network Service not decreases.
        //
        // Also this approach can show weather even if not all of cities are valid,
        // or if error occured in one of those requests.

        // Getting weather info of cities.

        let cities = storageService.getCities()

        cities.forEach { city in
            group.enter()

            networkService.getCurrentWeather(for: city) { [weak self] result in
                switch result {
                case .success(let data):
                    // Add weather info of a city.
                    self?.weatherData[.cities]?.append(data)
                case .failure(let error):
                    print(error)
                }

                group.leave()
            }
        }

        // Notify when async operations finished.
        group.notify(queue: .main) {

            // Stop refresh controll spinning.
            self.refreshControl.endRefreshing()

            // Reorder data.
            if self.weatherData[.cities]?.count ?? 0 > 0 {
                self.weatherData[.cities] = self.weatherData[.cities]?.reorder(by: cities)
            }

            // Reload Collection View.
            self.collectionView.reloadData()
        }
    }

    @objc func handleAddButton() {
        let alertController = UIAlertController(
            title: "Add city",
            message: "Submit a city name to see its weather on the main screen",
            preferredStyle: .alert)

        alertController.addTextField()

        let submitAction = UIAlertAction(title: "Submit", style: .default) { _ in
            let answer = alertController.textFields![0]

            guard let cityName = answer.text,
                  !cityName.isEmpty else {
                self.handleBadCityNameInput(cityName: "")
                return
            }

            var cities = self.storageService.getCities()

            self.networkService.getCurrentWeather(for: cityName) { [weak self] result in
                switch result {
                case .success(let data):
                    cities.append(cityName)
                    self?.storageService.setCities(cities: cities)
                    self?.weatherData[.cities]?.append(data)
                    self?.collectionView.reloadData()
                case .failure(let error):
                    self?.handleBadCityNameInput(cityName: cityName)
                    print(error)
                    return
                }
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alertController.addAction(submitAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true)
    }

    private func handleBadCityNameInput(cityName: String) {
        let alertController = UIAlertController(
            title: "Bad city name",
            message: "System can't find city with given name \(cityName)",
            preferredStyle: .alert)

        let action = UIAlertAction(title: "OK", style: .cancel)

        alertController.addAction(action)

        present(alertController, animated: true)
    }

    private func setupLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestLocation()
        }
    }

    private func setupNavigationBar() {
        title = "Current Weather"
        navigationController?.navigationBar.prefersLargeTitles = true

        navigationItem.setRightBarButton(
            UIBarButtonItem(
                barButtonSystemItem: .add,
                target: self,
                action: #selector(handleAddButton)),
            animated: true)
    }

    private func setupCollectionView() {

        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.backgroundColor = .systemBackground

        refreshControl.addTarget(self, action: #selector(getData), for: .valueChanged)
        collectionView.refreshControl = refreshControl

        view.addSubview(collectionView)

        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)

        collectionView.register(CurrentWeatherCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.register(HeaderViewCell.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "HeaderView")

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

}

extension CitiesViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        sections.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerCell = collectionView
                .dequeueReusableSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: "HeaderView", for: indexPath) as? HeaderViewCell
        else {
            fatalError("Could not cast cell as HeaderViewCell")
        }

        if collectionView.numberOfItems(inSection: indexPath.section) == 0 {
            headerCell.isHidden = true
            headerCell.frame = .zero
        } else {
            headerCell.isHidden = false
        }

        headerCell.label.text = sections[indexPath.section].rawValue
        headerCell.appear(delay: Double(indexPath.section) * 0.1)
        return headerCell
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {

        weatherData[sections[section]]?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView
                .dequeueReusableCell(withReuseIdentifier: "Cell",
                                     for: indexPath) as? CurrentWeatherCell
        else {
            fatalError("Could not cast cell as WeatherCell")
        }

        return setupCell(cell: cell, indexPath: indexPath)
    }

    func setupCell(cell: CurrentWeatherCell, indexPath: IndexPath) -> CurrentWeatherCell {

        cell.appear(delay: Double(indexPath.row) * 0.1)

        guard let sectionWeatherData = self
                .weatherData[sections[indexPath.section]] else {
            return cell
        }

        guard sectionWeatherData.count > indexPath.row else {
            return cell
        }

        let weatherData = sectionWeatherData[indexPath.row]

        cell.temperatureLabel.text = "\(Int(weatherData.main.temperature))°"

        cell.cityLabel.text = weatherData.city

        guard let weather = weatherData.weather.first else {
            return cell
        }

        cell.descriptionLabel.text = weather.main
        cell.iconName = weather.icon

        return cell
    }
}

extension CitiesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        guard let sectionWeatherData = self
                .weatherData[sections[indexPath.section]] else {
            return
        }

        guard sectionWeatherData.count > indexPath.row else {
            return
        }

        let weatherData = sectionWeatherData[indexPath.row]

        let detailedViewController = DetailedViewController()
        detailedViewController.currentWeather = weatherData

        showDetailViewController(detailedViewController, sender: self)
    }
}

extension CitiesViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // So I don't know if its ok to update data depending on can app access location or not,
        // but here is one of the only ways it's all working correctly. 
        getData()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            sections.insert(.location, at: 0)
            self.location = location
            getData()
        }
    }
}
