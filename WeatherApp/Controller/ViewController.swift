//
//  ViewController.swift
//  WeatherApp
//
//  Created by Vsevolod Pavlovskyi on 19.01.2021.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    // MARK: - Variables

    var dataService = NetworkService.shared

    var cities = [
        "Kyiv",
        "Dnipro",
        "London",
        "New York",
        "Moscow",
        "Seoul",
        "Beijing",
        "Honk Kong",
        "Minsk",
        "Mykolaiv"
    ]

    var data = [CurrentWeather]()

    let location = CLLocation.init(latitude: 47.333119, longitude: -53.323419)

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.bounds.width  - 30, height: 90)
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    lazy var refreshControl = UIRefreshControl()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Current Weather"
        navigationController?.navigationBar.prefersLargeTitles = true

        setupCollectionView()
        getData()
    }

    // MARK: - Methods

    @objc func getData() {

        let group = DispatchGroup()

        group.enter()
        dataService.getCurrentWeather(for: location) { [weak self] result in
            switch result {
            case .success(let data):
                self?.data.insert(data, at: 0)
            case .failure(let error):
                print(error)
            }

            group.leave()
        }

        group.enter()
        dataService.getCurrentWeather(for: self.cities) { [weak self] result in
            switch result {
            case .success(let data):
                self?.data = data
            case .failure(let error):
                print(error)
            }

            group.leave()
        }

        group.notify(queue: .main) {
            self.refreshControl.endRefreshing()

            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }

    private func setupCollectionView() {

        collectionView.dataSource = self

        collectionView.backgroundColor = .systemBackground

        refreshControl.addTarget(self, action: #selector(getData), for: .valueChanged)
        collectionView.refreshControl = refreshControl

        view.addSubview(collectionView)

        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)

//        collectionView.register(UINib(nibName: "CurrentWeatherCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        collectionView.register(CurrentWeatherCell.self, forCellWithReuseIdentifier: "Cell")

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

}

extension ViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
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

        cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        cell.alpha = 0

        UIView.animate(withDuration: 0.5,
                       delay: Double(indexPath.row) * 0.05,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 2,
                       options: .curveEaseInOut) {
            cell.transform = CGAffineTransform(scaleX: 1, y: 1)
            cell.alpha = 1
        }

        cell.cityLabel.text = data[indexPath.row].city

        cell.descriptionLabel.text = data[indexPath.row].weather.first?.main
        cell.temperatureLabel.text = "\(Int(data[indexPath.row].main.temperature))˚"

        return cell
    }
}
