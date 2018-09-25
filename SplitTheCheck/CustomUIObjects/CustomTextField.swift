//
//  CustomTextBox.swift
//  SplitTheCheck
//
//  Created by Anya on 25/09/2018.
//  Copyright © 2018 Anna Zhulidova. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class CustomTextField: UITextField {
    
    var padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    @IBInspectable var leftInset: CGFloat = 0{
        didSet{
            self.padding.left = leftInset
        }
    }
    
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
}
