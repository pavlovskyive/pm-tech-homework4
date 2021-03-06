//
//  HeaderViewCell.swift
//  WeatherApp
//
//  Created by Vsevolod Pavlovskyi on 21.01.2021.
//

import UIKit

class HeaderViewCell: UICollectionViewCell {

    lazy var label: UILabel = {

        let label = UILabel()
        label.textColor = .label
        label.font = .preferredFont(forTextStyle: .title3)
        label.textAlignment = .natural
        label.adjustsFontSizeToFitWidth = false

        label.frame = bounds

        return label
    }()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(label)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = bounds
    }
}
