//
//  ForecastDateHeaderCell.swift
//  WeatherApp
//
//  Created by Vsevolod Pavlovskyi on 22.01.2021.
//

import UIKit

class ForecastDateHeaderCell: UICollectionViewCell {

    var date: Date? {
        didSet {

            guard let date = date else {
                return
            }

            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM"

            dateLabel.text = Calendar.current.isDateInToday(date) ? "Today" : formatter.string(from: date)
        }
    }

    lazy var dateLabel: UILabel = {

        let label = UILabel()
        label.textColor = .white
        label.font = .preferredFont(forTextStyle: .headline)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true

        label.frame = bounds

        return label
    }()

    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(dateLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = bounds
    }
}

extension ForecastDateHeaderCell {

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
