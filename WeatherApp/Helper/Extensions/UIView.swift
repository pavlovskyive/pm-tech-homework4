//
//  UIView.swift
//  WeatherApp
//
//  Created by Vsevolod Pavlovskyi on 23.01.2021.
//

import UIKit

extension UIView {

    public func appear(delay: Double) {
        transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        alpha = 0

        UIView.animate(withDuration: 0.5,
                       delay: delay,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 2,
                       options: .curveEaseInOut) {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.alpha = 1
        }
    }
}
