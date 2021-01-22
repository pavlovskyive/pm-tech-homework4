//
//  ForecastCell.swift
//  WeatherApp
//
//  Created by Vsevolod Pavlovskyi on 22.01.2021.
//

import UIKit

class ForecastCell: UICollectionViewCell {

    var forecastItem: Hourly? {
        didSet {
            guard let forecastItem = forecastItem else {
                return
            }

            let date = Date(timeIntervalSince1970: forecastItem.dateTime)
            let calendar = Calendar.current
            if let hour = calendar.dateComponents([.hour], from: date).hour {
                timeLabel.text = String(format: "%02d", hour)
            }

            let iconName = forecastItem.weather.first?.icon ?? ""

            guard let systemName = iconCorrelation[iconName] else {
                return
            }

            let image = UIImage(systemName: systemName)
            iconImageView.image = image

            temperatureLabel.text = "\(Int(forecastItem.main.temperature))°"
        }
    }

    lazy var temperatureLabel: UILabel = {

        let label = UILabel()
        label.textColor = .white
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true

        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    lazy var timeLabel: UILabel = {

        let label = UILabel()
        label.textColor = .white
        label.font = .preferredFont(forTextStyle: .callout)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true

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
    }

    // MARK: - Setups

    private func setupCell() {
        translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(iconImageView)
        contentView.addSubview(temperatureLabel)
        contentView.addSubview(timeLabel)

        setLayoutConstraints()
    }

    private func setLayoutConstraints() {
        NSLayoutConstraint.activate([
            timeLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            timeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            timeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            iconImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 30),
            iconImageView.heightAnchor.constraint(equalTo: iconImageView.widthAnchor),

            temperatureLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            temperatureLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
}

extension ForecastCell {

    // Appear with animation.
    public func appear() {
        transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        alpha = 0

        UIView.animate(withDuration: 0.5,
                       delay: 0.2,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 2,
                       options: .curveEaseInOut) {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.alpha = 1
        }
    }
}
