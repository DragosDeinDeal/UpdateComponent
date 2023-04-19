//
//  UpdatePopup+Presenter.swift
//  DeinDeal
//
//  Created by Dragos Marinescu on 16.02.2023.
//  Copyright © 2023 Goodshine AG. All rights reserved.
//

import Foundation
import UIKit

// App store redirect
extension UpdatePopupImplementation {
    public func openStoreProductWithiTunesItemIdentifier(_ identifier: String) {
        if let url = URL(string: "https://apps.apple.com/us/app/id\(identifier)") {
            UIApplication.shared.open(url)
        }
        LoadingIndicator.hideSpinner()
    }
    
    func showForceUpdate() {
        let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        
        guard let window = window else { return }
        
        let title = stringsData.forceUpdatePopupLabelTitle
        let buttonTitle = stringsData.forceUpdatePopupButtonTitle
        
        topControllerDismissKeyboard()
        createForceUpdateAlert(for: window, title: title, buttonTitle: buttonTitle)
    }
    
    func showRecommendedUpdate() {
        if !usesCustomAlert {
            alertController = createDefaultShowUpdateAlert()
        }
        
        if let alert = alertController {
            topControllerDismissKeyboard()
            topControllerPresent(viewController: alert)
        }
    }
    
    private func topControllerDismissKeyboard() {
        let topController = getTopMostViewController()
        topController.view.endEditing(true)
    }
    
    private func topControllerPresent(viewController: UIViewController) {
        let topController = getTopMostViewController()
        if !(topController is DDAlertController) {
            topController.dismiss(animated: false)
            topController.present(viewController, animated: true, completion: nil)
        }
    }
    
    func getTopMostViewController() -> UIViewController {
        let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        if var topController = window?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return UIViewController()
    }
    
}
