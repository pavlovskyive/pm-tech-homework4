//
//  CurrentWeatherCell.swift
//  WeatherApp
//
//  Created by Vsevolod Pavlovskyi on 20.01.2021.
//

import UIKit

class CurrentWeatherCell: UICollectionViewCell {

    var iconName: String = "sun.min" {
        didSet {
            guard let systemName = iconMap[iconName] else {
                return
            }

            let image = UIImage(systemName: systemName)
            iconImageView.image = image
        }
    }

    lazy var temperatureLabel: UILabel = {

        let label = UILabel()
        label.textColor = .white
        label.font = .preferredFont(forTextStyle: .largeTitle)
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true

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
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit

        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()

    lazy private var gradientBackground: UIView = {
        let view = GradientBackgroud()
        view.colors = (UIColor.systemBlue, UIColor.systemTeal)
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupCell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setups

    private func setupCell() {
        translatesAutoresizingMaskIntoConstraints = false

        setCornerRadius()

        contentView.addSubview(gradientBackground)
        contentView.addSubview(iconImageView)
        contentView.addSubview(temperatureLabel)
        contentView.addSubview(cityLabel)
        contentView.addSubview(descriptionLabel)

        setLayoutConstraints()
    }

    private func setLayoutConstraints() {
        NSLayoutConstraint.activate([
            gradientBackground.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            gradientBackground.heightAnchor.constraint(equalTo: contentView.heightAnchor),
            gradientBackground.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            gradientBackground.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            temperatureLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            temperatureLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            temperatureLabel.widthAnchor.constraint(equalToConstant: 60),

            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -5),
            iconImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            iconImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.5),
            iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor),

            cityLabel.bottomAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: -5),
            cityLabel.leadingAnchor.constraint(equalTo: temperatureLabel.trailingAnchor, constant: 5),
            cityLabel.trailingAnchor.constraint(equalTo: iconImageView.leadingAnchor, constant: -5),

            descriptionLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 0),
            descriptionLabel.centerXAnchor.constraint(equalTo: iconImageView.centerXAnchor)
        ])
    }

    private func setCornerRadius() {
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.clear.cgColor
    }
}
