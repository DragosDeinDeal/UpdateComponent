//
//  DDAlertButton.swift
//  DeinDeal
//
//  Created by Mihai Honceriu on 17/06/2020.
//  Copyright © 2020 Goodshine AG. All rights reserved.
//

import Foundation
import UIKit
class DDAlertButton: UIButton {
  
    var action : DDAlertAction
    
    init(action: DDAlertAction) {
        self.action = action
        super.init(frame: .zero)
        if let font = action.buttonFont {
            titleLabel?.font = font
        } else {
            titleLabel?.font = UIFont.boldDDFontOfSize(14)
        }

        setTitleColor(action.color, for: .normal)
        setTitle(action.title, for: .normal)
        addTarget(action, action: #selector(action.executeAction), for: .touchUpInside)
        
        if action.hasUnderbar {
            let bar = UIView()
            self.addSubview(bar)
            bar.activateConstraints([
                bar.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
                bar.widthAnchor.constraint(equalToConstant: 50),
                bar.heightAnchor.constraint(equalToConstant: 5),
                bar.centerXAnchor.constraint(equalTo: self.centerXAnchor)])
            bar.backgroundColor = UIColor.red1
        }
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
