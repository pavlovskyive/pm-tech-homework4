//
//  GradientBackgroud.swift
//  WeatherApp
//
//  Created by Vsevolod Pavlovskyi on 23.01.2021.
//

import UIKit

class GradientBackgroud: UIView {

    private let gradientLayer = CAGradientLayer()

    var colors: (UIColor, UIColor)? {
        didSet {
            guard let colors = colors else {
                return
            }

            setGradientBackgroundColor(colorOne: colors.0, colorTwo: colors.1)
        }
    }

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        gradientLayer.frame = bounds
    }

    // MARK: - Setups

    private func setGradientBackgroundColor(colorOne: UIColor, colorTwo: UIColor) {
        gradientLayer.frame = bounds
        gradientLayer.colors = [colorOne.cgColor, colorTwo.cgColor]
        gradientLayer.locations = [0.0, 1.1]
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.cornerRadius = 3

        layer.insertSublayer(gradientLayer, at: 0)
    }
}
