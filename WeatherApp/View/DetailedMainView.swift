//
//  DetailedMainView.swift
//  WeatherApp
//
//  Created by Vsevolod Pavlovskyi on 22.01.2021.
//

import UIKit

class DetailedMainView: UIView {

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

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
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
            cityLabel.bottomAnchor.constraint(equalTo: desriptionLabel.topAnchor, constant: -2)
        ])
    }

}
