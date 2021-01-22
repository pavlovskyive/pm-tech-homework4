//
//  DetailedViewController.swift
//  WeatherApp
//
//  Created by Vsevolod Pavlovskyi on 22.01.2021.
//

import UIKit

class DetailedViewController: UIViewController {

    let dataService = NetworkService.shared

    var currentWeather: CurrentWeather?
    var forecast: Forecast?

    lazy var mainView = DetailedMainView()

    lazy var forecastTitle: UILabel = {
        let label = UILabel()
        label.textColor = .init(white: 1, alpha: 0.9)
        label.font = .preferredFont(forTextStyle: .title1)
        label.text = "Forecast"

        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()

        layout.sectionInset = UIEdgeInsets(
            top: 0, left: 10, bottom: 0, right: 10)

        layout.itemSize = CGSize(width: 50, height: 80)
        layout.headerReferenceSize = CGSize(width: 60, height: 80)

        layout.scrollDirection = .horizontal

        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        updateCurrentWeatherUI()

        getData()
        // Do any additional setup after loading the view.
    }

    func setupView() {
        view.backgroundColor = .systemTeal
        view.addSubview(mainView)
        view.addSubview(collectionView)
        view.addSubview(forecastTitle)

        setupCollectionView()
        setLayoutConstraints()
    }

    private func setupCollectionView() {

        collectionView.dataSource = self

        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear

        collectionView.alwaysBounceHorizontal = true
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 10)

        collectionView.register(ForecastCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.register(ForecastDateHeaderCell.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "HeaderCell")
    }

    func setLayoutConstraints() {
        mainView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -10),
            collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            collectionView.widthAnchor.constraint(equalTo: view.widthAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 100),

            forecastTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            forecastTitle.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40),
            forecastTitle.bottomAnchor.constraint(equalTo: collectionView.topAnchor),

            mainView.topAnchor.constraint(equalTo: view.topAnchor),
            mainView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainView.widthAnchor.constraint(equalTo: view.widthAnchor),
            mainView.bottomAnchor.constraint(equalTo: forecastTitle.topAnchor)
        ])
    }

    func getData() {

        guard let city = currentWeather?.city else {
            return
        }

        dataService.getForecast(for: city) { [weak self] result in
            switch result {
            case .success(let data):
                self?.forecast = data
                self?.collectionView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }

    func updateCurrentWeatherUI() {

        guard let currentWeather = currentWeather else {
            return
        }

        mainView.weather = currentWeather
    }

}

extension DetailedViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        forecast?.grouped().count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        guard let forecast = forecast else {
            return 0
        }

        let key = Array(forecast.grouped().keys).sorted(by: <)[section]

        return forecast.grouped()[key]?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerCell = collectionView
                .dequeueReusableSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: "HeaderCell", for: indexPath) as? ForecastDateHeaderCell
        else {
            fatalError("Could not cast cell as HeaderViewCell")
        }

        guard let forecast = forecast else {
            return headerCell
        }

        let date = Array(forecast.grouped().keys)
            .sorted(by: <)[indexPath.section]

        headerCell.date = date

        headerCell.appear()
        return headerCell
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView
                .dequeueReusableCell(withReuseIdentifier: "Cell",
                                     for: indexPath) as? ForecastCell
        else {
            fatalError("Could not cast cell as ForecastCell")
        }

        guard let forecast = forecast else {
            return cell
        }

        let key = Array(forecast.grouped().keys).sorted(by: <)[indexPath.section]

        guard let forecastDay = forecast.grouped()[key] else {
            return cell
        }

        cell.forecastItem = forecastDay[indexPath.row]
        cell.appear()

        return cell
    }
}
