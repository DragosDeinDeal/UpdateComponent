//
//  UpdatePopupLoading.swift
//  DeinDeal
//
//  Created by Dragos Marinescu on 22.02.2023.
//  Copyright © 2023 Goodshine AG. All rights reserved.
//

import Foundation
import UIKit

class LoadingIndicator {
    static var spinner = UIActivityIndicatorView(style: .large)
    static var view: UIView = UIView()
    
    static func showSpinner() {
        let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        guard let window = keyWindow else { return }
        
        view.frame = window.frame
        view.backgroundColor = .black
        view.alpha = 0.3
        
        window.addSubview(view)
        view.addSubview(spinner)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        spinner.startAnimating()
    }
    
    static func hideSpinner() {
        view.removeFromSuperview()
    }
}


