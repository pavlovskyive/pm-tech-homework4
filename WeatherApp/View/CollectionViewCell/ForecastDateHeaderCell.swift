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
