//
//  DDAlertAction.swift
//  DeinDeal
//
//  Created by Mihai Honceriu on 17/06/2020.
//  Copyright © 2020 Goodshine AG. All rights reserved.
//

import Foundation
import UIKit

public class DDAlertController: UIViewController {
    enum AlertBackgroundMode {
        case flat
        case blur(style: UIBlurEffect.Style)
    }

    static let messageFont : UIFont = UIFont.ddFontOfSize(14)
    static let titleFont : UIFont = UIFont.boldDDFontOfSize(14)
    private var actions : [DDAlertAction] = []
    var buttonActions: [DDAlertButton] = []
    var isDismissable : Bool = true
    var isLoading : Bool = false
    var hasTextField: Bool = false
    private var backgroundMode : AlertBackgroundMode
    private var blurEffectView : UIVisualEffectView?
    private var textFieldDelegate: UITextFieldDelegate?
    var alertViewCenterYconstraint: NSLayoutConstraint?

    lazy private(set) var backgroundTransparentView : UIView = {
        let v = UIView()
        v.tag = 20
        if(self.isDismissable == true){
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissController))
            tapGesture.numberOfTapsRequired = 1
            v.addGestureRecognizer(tapGesture)
        }
        self.view.addSubview(v)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.activateConstraints([v.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
                               v.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
                               v.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
                               v.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0)])
        v.backgroundColor = UIColor(white: 0, alpha: 0.17)
        
        return v
    }()
    
    lazy private(set) var alertView : UIView = {
        let v = UIView()
        self.view.addSubview(v)
        v.tag = 30
        v.backgroundColor = UIColor.white
        alertViewCenterYconstraint = v.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0)
        
        v.activateConstraints([
            alertViewCenterYconstraint!,
            v.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
            v.widthAnchor.constraint(equalToConstant: 260)])
        v.layer.cornerRadius = 20
        return v
    }()
    
    lazy private(set) var titleLabel : UILabel = {
       let l = UILabel()
        alertView.addSubview(l)
        l.activateConstraints([
            l.topAnchor.constraint(equalTo: alertView.topAnchor, constant: 30),
            l.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 15),
            l.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -15)])
        l.numberOfLines = 3
        l.font = DDAlertController.titleFont
        l.textAlignment = .center
        l.textColor = UIColor.black
        return l
    }()
    
    lazy private(set) var messageLabel : UILabel = {
        let l = UILabel()
        alertView.addSubview(l)
        l.activateConstraints([
            l.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            l.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 17),
            l.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -17)])
        
        l.numberOfLines = 0
        l.lineBreakMode = .byWordWrapping
        l.font = DDAlertController.messageFont
        l.textColor = UIColor.gray(value: 151)
        l.textAlignment = .center
        return l
    }()
  
    lazy private(set) var textField: UITextField = {
      let textField = UITextField()
      textField.borderStyle = .roundedRect
      textField.isSecureTextEntry = true
      
      alertView.addSubview(textField)
      
      textField.activateConstraints([
        textField.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20),
        textField.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 17),
        textField.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -17)])
      
      textField.delegate = textFieldDelegate
      
      return textField
    }()
    
    lazy var actionsStackView : UIStackView = {
       let sv = UIStackView()
        alertView.addSubview(sv)
        sv.distribution = .fillProportionally
        sv.axis = .vertical
        sv.activateConstraints([
            sv.topAnchor.constraint(equalTo: hasTextField ? textField.bottomAnchor : messageLabel.bottomAnchor, constant: 20),
            sv.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 0),
            sv.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: 0),
            sv.bottomAnchor.constraint(equalTo: alertView.bottomAnchor, constant: -10)])
        
        return sv
    }()
    
    func commonInit(title: String, message: Any, actions: [DDAlertAction] = [], backgroundColor: UIColor = UIColor.black, backgroundAlpha: CGFloat = 0.5) {
        self.transitioningDelegate = self
        self.modalPresentationStyle = .custom
        view.backgroundColor = UIColor.clear
        self.actions = actions
        _ = backgroundTransparentView
        self.titleLabel.text = title
        
        switch backgroundMode {
        case .blur(let _):
            backgroundTransparentView.backgroundColor = UIColor.clear
        case .flat:
            backgroundTransparentView.backgroundColor = backgroundColor.withAlphaComponent(backgroundAlpha)
        }
      
        if hasTextField {
          _ = textField
        }
        
        if let message = message as? String {
            self.messageLabel.text = message
            self.messageLabel.attributedText = NSAttributedString(string: message).withLineSpacing(5.5, andAlignment: .center)
        } else if let message = message as? NSAttributedString {
            self.messageLabel.attributedText = message.withLineSpacing(5.5, andAlignment: .center)
        } else {
            self.messageLabel.text = ""
        }
        
//        reloadActions()
    }
    
    init(title: String, message: String, actions: [DDAlertAction] = [], backgroundMode: AlertBackgroundMode = .flat, backgroundColor: UIColor = UIColor.black, backgroundAlpha: CGFloat = 0.5) {
        self.backgroundMode = backgroundMode
        super.init(nibName: nil, bundle: nil)
        commonInit(title: title, message: message, actions: actions, backgroundColor: backgroundColor, backgroundAlpha: backgroundAlpha)
    }
  
    init(title: String, message: String, hasTextInput: Bool, fieldDelegate: UITextFieldDelegate?, actions: [DDAlertAction] = [], backgroundMode: AlertBackgroundMode = .flat, backgroundColor: UIColor = UIColor.black, backgroundAlpha: CGFloat = 0.5) {
        self.hasTextField = hasTextInput
        self.textFieldDelegate = fieldDelegate
        self.backgroundMode = backgroundMode
        super.init(nibName: nil, bundle: nil)
        commonInit(title: title, message: message, actions: actions, backgroundColor: backgroundColor, backgroundAlpha: backgroundAlpha)
    }
    
    init(title: String, message: NSAttributedString, actions: [DDAlertAction] = [], backgroundMode: AlertBackgroundMode = .flat, backgroundColor: UIColor = UIColor.black, backgroundAlpha: CGFloat = 0.5) {
        self.backgroundMode = backgroundMode
        super.init(nibName: nil, bundle: nil)
       commonInit(title: title, message: message, actions: actions, backgroundColor: backgroundColor, backgroundAlpha: backgroundAlpha)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func dismissController() {
        if actions.count == 0 && self.isDismissable == true {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func addingAction(action: DDAlertAction) -> DDAlertController {
        self.addNewAction(action: action)
        return self
    }
    
    func addNewAction(action: DDAlertAction) {
        action.dismissAlert = {
            self.dismiss(animated: true) {
                if let handler = action.handler {
                    handler()
                }
            }
        }
        actions.append(action)
    }
    
    
    private func addActionButton(withAction action: DDAlertAction) {
        if action.dismissAlert == nil {
              action.dismissAlert = {
                      self.dismiss(animated: true) {
                          if let handler = action.handler {
                              handler()
                          }
                      }
                  }
        }
        
        let actionButton = DDAlertButton(action: action)
        buttonActions.append(actionButton)
        actionsStackView.addArrangedSubview(actionButton)
    }
    
    private func reloadActions() {
        for view in actionsStackView.subviews {
            actionsStackView.removeArrangedSubview(view)
        }
        
        guard actions.count > 0 else {
            if isDismissable == true {
                addActionButton(withAction: DDAlertAction.dismiss)
            } else if isLoading == true {
                //Add progress view
            }
            return
        }
        
        for action in actions {
            addActionButton(withAction: action)
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        switch backgroundMode {
        case .blur(let style):
            blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: style))
            blurEffectView?.frame = UIScreen.main.bounds
            blurEffectView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            backgroundTransparentView.backgroundColor = UIColor.clear
            backgroundTransparentView.insertSubview(blurEffectView!, at: 0)
        default:
            break
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadActions()
        
      if hasTextField {
        buttonActions[1].isEnabled = false
        buttonActions[1].setTitleColor(.grey3, for: .normal)
      }
    }
  
  func addRangeGestureForString(_ message: String, handler: @escaping () -> Void) {
      messageLabel.addRangeGesture(stringRange: message, function: handler)
  }
  
}

extension DDAlertController : UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return UTAlertControllerAnimator(duration: 0.5, isPresenting: true)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return UTAlertControllerAnimator(duration: 0.5, isPresenting: false)
    }
}

class UTAlertControllerAnimator :NSObject, UIViewControllerAnimatedTransitioning {
    
    var duration : TimeInterval
    var isPresenting : Bool
    
    init(duration : TimeInterval, isPresenting : Bool) {
           self.duration = duration
           self.isPresenting = isPresenting
       }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let container = transitionContext.containerView
        var alertControllerView : UIView?
        if isPresenting {
            alertControllerView = transitionContext.view(forKey: .to)
        } else {
            alertControllerView = transitionContext.view(forKey: .from)
        }
        
        guard let temporaryView = alertControllerView else {
            return
        }
        
        
        temporaryView.frame = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.height))
        
        container.addSubview(temporaryView)
        
        let background = temporaryView.viewWithTag(20)
        let alert = temporaryView.viewWithTag(30)
        
        if isPresenting {
            background?.alpha = 0
            alert?.transform = CGAffineTransform(scaleX: 0, y: 0)
        }
        
        UIView.animate(withDuration: 0.2) {
            background?.alpha = self.isPresenting ? 1 : 0
        }
        
        UIView.animate(withDuration: isPresenting ? duration : 0.2, delay: 0, usingSpringWithDamping: isPresenting ? 0.7 : 1, initialSpringVelocity: isPresenting ? 0.4 : 0, options: .curveEaseIn, animations: {
            if self.isPresenting {
                alert?.transform =  CGAffineTransform.identity

            } else {
                alert?.alpha = 0
                alert?.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            }
            
            }) { (finished) in
                if !self.isPresenting{
                    temporaryView.removeFromSuperview()
                }
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                
        }
    }
    
}

