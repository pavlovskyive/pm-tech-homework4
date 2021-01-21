//
//  CurrentWeatherCell.swift
//  WeatherApp
//
//  Created by Vsevolod Pavlovskyi on 20.01.2021.
//

import UIKit

class CurrentWeatherCell: UICollectionViewCell {

    lazy var temperatureLabel: UILabel = {

        let label = UILabel()
        label.textColor = .white
        label.font = .preferredFont(forTextStyle: .largeTitle)
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = false

        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    lazy var cityLabel: UILabel = {

        let label = UILabel()
        label.textColor = .white
        label.font = .preferredFont(forTextStyle: .title3)
        label.textAlignment = .natural
        label.adjustsFontSizeToFitWidth = false

        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = false

        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "sun.min")
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit

        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()

    private let gradientLayer = CAGradientLayer()

    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupCell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = bounds
        gradientLayer.frame = bounds
    }

    // MARK: - Setups

    func setupCell() {
        translatesAutoresizingMaskIntoConstraints = false

        setCornerRadius()
        setGradientBackgroundColor(colorOne: .systemBlue,
                                   colorTwo: .systemTeal)

        contentView.addSubview(iconImageView)
        contentView.addSubview(temperatureLabel)
        contentView.addSubview(cityLabel)
        contentView.addSubview(descriptionLabel)

        setLayoutConstraints()
    }

    func setLayoutConstraints() {
        NSLayoutConstraint.activate([
            temperatureLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            temperatureLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            temperatureLabel.widthAnchor.constraint(equalToConstant: 90),

            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -5),
            iconImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            iconImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.5),
            iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor),

            cityLabel.bottomAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: -5),
            cityLabel.leadingAnchor.constraint(equalTo: temperatureLabel.trailingAnchor),
            cityLabel.trailingAnchor.constraint(equalTo: iconImageView.leadingAnchor),

            descriptionLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 0),
            descriptionLabel.centerXAnchor.constraint(equalTo: iconImageView.centerXAnchor)
        ])
    }

    private func setGradientBackgroundColor(colorOne: UIColor, colorTwo: UIColor) {
        gradientLayer.frame = bounds
        gradientLayer.colors = [colorOne.cgColor, colorTwo.cgColor]
        gradientLayer.locations = [0.0, 1.1]
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.cornerRadius = 3

        contentView.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setCornerRadius() {
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.clear.cgColor
    }
}
