//
//  CustomLabel.swift
//  SplitTheCheck
//
//  Created by Anya on 30/10/2018.
//  Copyright © 2018 Anna Vondrukhova. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class CustomLabel: UILabel {
    
    var padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    @IBInspectable var leftInset: CGFloat = 0{
        didSet{
            self.padding.left = leftInset
        }
    }
    
    @IBInspectable var rightInset: CGFloat = 0{
        didSet{
            self.padding.left = rightInset
        }
    }
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: padding.top, left: leftInset, bottom: padding.bottom, right: rightInset)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            var contentSize = super.intrinsicContentSize
            contentSize.height += padding.top + padding.bottom
            contentSize.width += leftInset + rightInset
            return contentSize
        }
    }
}
