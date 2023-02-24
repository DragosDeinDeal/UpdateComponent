//
//  File.swift
//  
//
//  Created by Dragos Marinescu on 23.02.2023.
//

import UIKit

extension UIView {
    func activateConstraints(_ constraints: [NSLayoutConstraint]) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(constraints)
    }
}

extension UIColor {
    static func gray(value: Int, alpha: Double? = 1) -> UIColor {
        return UIColor(red: CGFloat(value)/255.0, green: CGFloat(value)/255.0, blue: CGFloat(value)/255.0, alpha: 1)
    }
    
    static var red1: UIColor {
        return UIColor(red: 192/255, green: 28/255, blue: 60/255, alpha: 1.0)
    }
    
    static var grey3: UIColor {
        return UIColor(red: 214/255, green: 214/255, blue: 214/255, alpha: 1.0)
    }
    
    static var dark: UIColor {
        return UIColor(red: 47/255, green: 47/255, blue: 47/255, alpha: 1.0)
    }
}

extension UILabel {
    typealias MethodHandler = () -> Void

    func addRangeGesture(stringRange: String, function: @escaping MethodHandler) {
        RangeGestureRecognizer.stringRange = stringRange
        RangeGestureRecognizer.function = function
        self.isUserInteractionEnabled = true
        let tapgesture: UITapGestureRecognizer = RangeGestureRecognizer(target: self, action: #selector(tappedOnLabel(_ :)))
        tapgesture.numberOfTapsRequired = 1
        
        self.addGestureRecognizer(tapgesture)
    }
    
    @objc func tappedOnLabel(_ gesture: RangeGestureRecognizer) {
        guard let text = self.text else { return }
        let stringRange = (text as NSString).range(of: RangeGestureRecognizer.stringRange ?? "")
        if gesture.didTapAttributedTextInLabel(label: self, inRange: stringRange) {
            guard let existedFunction = RangeGestureRecognizer.function else { return }
            existedFunction()
        }
    }
}

class RangeGestureRecognizer: UITapGestureRecognizer {
  typealias MethodHandler = () -> Void
  static var stringRange: String?
  static var function: MethodHandler?
  
  func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
      let layoutManager = NSLayoutManager()
      let textContainer = NSTextContainer(size: CGSize.zero)
      
      guard let attributedString = label.attributedText else { return false }

      let mutableAttribString = NSMutableAttributedString(attributedString: attributedString)
      mutableAttribString.addAttributes([NSAttributedString.Key.font: UIFont.ddFontOfSize(14)], range: NSRange(location: 0, length: attributedString.length))

      let textStorage = NSTextStorage(attributedString: mutableAttribString)
    
      layoutManager.addTextContainer(textContainer)
      textStorage.addLayoutManager(layoutManager)
    
      textContainer.lineFragmentPadding = 0.0
      textContainer.lineBreakMode = label.lineBreakMode
      textContainer.maximumNumberOfLines = label.numberOfLines
      let labelSize = label.bounds.size
      textContainer.size = labelSize
      
      let locationOfTouchInLabel = self.location(in: label)
      let textBoundingBox = layoutManager.usedRect(for: textContainer)
      let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                        y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
      let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
                                                   y: locationOfTouchInLabel.y - textContainerOffset.y);
      let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

      return NSLocationInRange(indexOfCharacter, targetRange)
    }
}

extension UIFont {
    class func boldDDFontOfSize(_ size: CGFloat) -> UIFont {
        return UIFont(name: "AvenirNext-Bold", size: size)!
    }
    class func ddFontOfSize(_ size: CGFloat) -> UIFont {
        return UIFont(name: "AvenirNext-Regular", size: size)!
    }
    class func demiBoldDDFontOfSize(_ size: CGFloat) -> UIFont {
        return UIFont(name: "AvenirNext-DemiBold", size: size)!
    }
    class func mediumDDFontOfSize(_ size: CGFloat) -> UIFont {
        return UIFont(name: "AvenirNext-Medium", size: size)!
    }
}

extension String {
    var integerValue: Int {
        return Int(self) ?? 0
    }
}

extension NSAttributedString {
    func withLineSpacing(_ spacing: CGFloat, andAlignment alignment: NSTextAlignment = .left) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(attributedString: self)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = spacing
        paragraphStyle.alignment = alignment
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        return attributedString
    }
}
