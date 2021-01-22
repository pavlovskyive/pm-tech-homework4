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

    var dataService = NetworkService.shared
    let locationManager = CLLocationManager()

    enum Section: String, CaseIterable {
        case location = "Weather by location"
        case cities = "Weather in added cities"
    }

    var cities = [
        "Kyiv",
        "Dnipro",
        "London",
        "New York",
        "Moscow",
        "Seoul",
        "Beijing",
        "Hong Kong",
        "Minsk",
        "Mykolaiv"
    ]

    var weatherData = [Section: [CurrentWeather]]()

    // Sample location data.
    var location: CLLocation? {
        didSet {
            getData()
        }
    }

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

        title = "Current Weather"
        navigationController?.navigationBar.prefersLargeTitles = true

        setupLocation()
        setupCollectionView()
        getData()
    }

    // MARK: - Methods

    @objc private func getData() {

        // Delete old data
        weatherData[.location] = []
        weatherData[.cities] = []

        // Create Dispatch Group.
        let group = DispatchGroup()

        // First async -- Getting weather info of current location.
        if let location = location {
            group.enter()
            dataService.getCurrentWeather(for: location) { [weak self] result in
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
        cities.forEach { city in
            group.enter()

            dataService.getCurrentWeather(for: city) { [weak self] result in
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
                self.weatherData[.cities] = self.weatherData[.cities]?.reorder(by: self.cities)
            }

            // Reload Collection View.
            self.collectionView.reloadData()
        }
    }

    private func setupLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestLocation()
        }
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
        weatherData.count
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

        headerCell.label.text = Section.allCases[indexPath.section].rawValue
        headerCell.appear(order: indexPath.section)
        return headerCell
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {

        weatherData[Section.allCases[section]]?.count ?? 0
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

        cell.appear(order: indexPath.row)

        guard let sectionWeatherData = self
                .weatherData[Section.allCases[indexPath.section]] else {
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
                .weatherData[Section.allCases[indexPath.section]] else {
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
         print("error:: \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.location = location
        }
    }
}
