//
//  DetailedMainView.swift
//  WeatherApp
//
//  Created by Vsevolod Pavlovskyi on 22.01.2021.
//

import UIKit

class DetailedMainView: UIView {

    var weather: CurrentWeather? {
        didSet {
            guard let weather = weather else {
                return
            }

            cityLabel.text = weather.city
            temperatureLabel.text = "\(Int(weather.main.temperature))°"
            desriptionLabel.text = weather.weather.first?.main

            guard let icon = weather.weather.first?.icon,
                  let systemName = iconMap[icon] else {
                return
            }

            let image = UIImage(systemName: systemName)
            iconImageView.image = image
        }
    }

    lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 80, weight: .light)
        label.textAlignment = .center

        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    lazy var cityLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .preferredFont(forTextStyle: .title1)
        label.textAlignment = .center

        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    lazy var desriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .init(white: 1, alpha: 0.8)
        label.font = .preferredFont(forTextStyle: .callout)
        label.textAlignment = .center

        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .init(white: 1, alpha: 0.1)
        imageView.contentMode = .scaleAspectFit

        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        addSubview(iconImageView)
        addSubview(temperatureLabel)
        addSubview(cityLabel)
        addSubview(desriptionLabel)

        setLayoutConstraints()
    }

    private func setLayoutConstraints() {
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            temperatureLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 10),
            temperatureLabel.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 15),

            desriptionLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            desriptionLabel.bottomAnchor.constraint(equalTo: temperatureLabel.topAnchor),

            cityLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            cityLabel.bottomAnchor.constraint(equalTo: desriptionLabel.topAnchor, constant: -2),

            iconImageView.widthAnchor.constraint(equalTo: widthAnchor),
            iconImageView.heightAnchor.constraint(equalTo: iconImageView.widthAnchor),
            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor,
                                                   constant: CGFloat.random(in: -80...80)),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor,
                                                   constant: CGFloat.random(in: -80...80))
        ])
    }
}
