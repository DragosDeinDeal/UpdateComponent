//
//  UpdatePopupViews.swift
//  DeinDeal
//
//  Created by Dragos Marinescu on 16.02.2023.
//  Copyright © 2023 Goodshine AG. All rights reserved.
//

import Foundation
import UIKit

extension UpdatePopupImplementation {
    func createForceUpdateAlert(for window: UIWindow, title: String, buttonTitle: String) {
        let view = UIView()
        window.addSubview(view)
        view.backgroundColor = .white
        view.frame = window.frame
        
        let label = UILabel()
        label.font = UIFont.demiBoldDDFontOfSize(UIDevice.current.userInterfaceIdiom == .pad ? 20 : 16)
        label.textAlignment = .center
        label.textColor = .dark
        label.text = title
        label.numberOfLines = 0
        
        window.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.activateConstraints([label.centerXAnchor.constraint(equalTo: window.centerXAnchor),
                                   label.centerYAnchor.constraint(equalTo: window.centerYAnchor),
                                   label.widthAnchor.constraint(equalToConstant: UIDevice.current.userInterfaceIdiom == .pad ? 450 : 280)])
        
        let button = UIButton()
        button.setTitle(buttonTitle, for: .normal)
        button.addTarget(self, action: #selector(updateButtonAction), for: .touchUpInside)
        button.backgroundColor = UIColor.red1
        
        button.titleLabel?.numberOfLines             = 0
        button.titleLabel?.textAlignment             = .center
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor        = 0.7
        button.titleLabel?.font                      = UIDevice.current.userInterfaceIdiom == .pad ?
            .mediumDDFontOfSize(20) :
            .demiBoldDDFontOfSize(15)

        button.layer.shadowOffset  = CGSize(width: 0.5, height: 0.5)
        button.layer.shadowRadius  = 1
        button.layer.shadowOpacity = 0.5
        button.layer.cornerRadius  = 4
        
        window.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.activateConstraints([button.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: 50),
                                    button.trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: -50),
                                   button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20),
                                    button.heightAnchor.constraint(equalToConstant: UIDevice.current.userInterfaceIdiom == .pad ? 53 : 44)])
    }
    
    public func createDefaultShowUpdateAlert() -> DDAlertController {
        let cancelAction = DDAlertAction(title: stringsData.updatePopupCancelButtonTitle) {
            UserDefaults.standard.set(Date(), forKey: updatePopupDateKey)
        }
        let updateAction = DDAlertAction(title: stringsData.updatePopupButtonTitle) {
            self.updateButtonAction()
        }
        
        let alertTitle = stringsData.updatePopupTitle
        let alertMessage = stringsData.updatePopupMessage
        
        
        return DDAlertController(title: alertTitle, message: alertMessage, actions: [updateAction, cancelAction], backgroundColor: .clear)
    }
}
