//
//  UpdatePopup+Presenter.swift
//  DeinDeal
//
//  Created by Dragos Marinescu on 16.02.2023.
//  Copyright © 2023 Goodshine AG. All rights reserved.
//

import Foundation
import StoreKit

// App store redirect
extension UpdatePopupImplementation: SKStoreProductViewControllerDelegate {
    public func openStoreProductWithiTunesItemIdentifier(_ identifier: String) {
        let storeViewController = SKStoreProductViewController()
        storeViewController.delegate = self
        
        let parameters = [SKStoreProductParameterITunesItemIdentifier : identifier]
        storeViewController.loadProduct(withParameters: parameters) { [weak self] (loaded, error) in
            if let skError = error {
                LoadingIndicator.hideSpinner()
                print("Store Kit ERROR: $$$", skError)
            }
            if loaded {
                LoadingIndicator.hideSpinner()
                self?.topControllerPresent(viewController: storeViewController)
            }
        }
    }
    
    public func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func showForceUpdate() {
        let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        
        guard let window = window else { return }
        
        let title = stringsData.forceUpdatePopupLabelTitle
        let buttonTitle = stringsData.forceUpdatePopupButtonTitle
        createForceUpdateAlert(for: window, title: title, buttonTitle: buttonTitle)
    }
    
    func showRecommendedUpdate() {
        if !usesCustomAlert {
            alertController = createDefaultShowUpdateAlert()
        }
        
        if let alert = alertController {
            topControllerPresent(viewController: alert)
        }
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
            while let presentedViewController = topController.presentedViewController, !(topController.presentedViewController is SKStoreProductViewController) {
                topController = presentedViewController
            }
            return topController
        }
        return UIViewController()
    }
    
}
