//
//  DDAlertController.swift
//  DeinDeal
//
//  Created by Mihai Honceriu on 17/06/2020.
//  Copyright © 2020 Goodshine AG. All rights reserved.
//

import Foundation
import UIKit

class DDAlertAction : NSObject {
    var handler : (() -> Void)?
    var dismissAlert : (() -> Void)?
    private(set) var title : String?
    var color : UIColor?
    var hasUnderbar : Bool = false
    var buttonFont : UIFont?
    
    static var dismiss : DDAlertAction {
        return DDAlertAction(title: "Dismiss", nil, color: UIColor.black)
    }
    
    init(title: String, _ handler: (() -> Void)? = nil, color: UIColor = UIColor.red1) {
        self.handler = handler
        self.title = title
        self.color = color
    }
    
    @objc func executeAction() {
        guard let dismissAlert = self.dismissAlert else {
            return
        }
        dismissAlert()
    }
    
    deinit {
        print("UTAlertAction did deinit")
    }
}
