//
//  ErrorDisplayable.swift
//  WeatherApp
//
//  Created by Vsevolod Pavlovskyi on 24.01.2021.
//

import UIKit

protocol Alertable: UIViewController {
    func displayError(_ errorText: String)
}

extension Alertable {

    // Default implementation.
    func displayError(_ errorText: String) {
        let alertController = UIAlertController(
            title: "Something went wrong",
            message: errorText,
            preferredStyle: .alert)

        let action = UIAlertAction(title: "OK", style: .cancel)

        alertController.addAction(action)

        if self.presentedViewController == nil {
            self.present(alertController, animated: true)
        }
    }
}
