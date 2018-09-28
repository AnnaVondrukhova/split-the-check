//
//  CustomButton.swift
//  App_Lvl2
//
//  Created by Anya on 22/12/2017.
//  Copyright © 2017 Anna Zhulidova. All rights reserved.
//

import UIKit

@IBDesignable
class CustomButton: UIButton {
    var isFolded = false
    
    //добавляем возможность установки радиуса скругления угла, ширины и цвета границы кнопки через Attributes inspector
    @IBInspectable var cornerRadius: CGFloat = 0{
        didSet{
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0{
        didSet{
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear{
        didSet{
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    //функция для превращения цвета в картинку и установки этой картинки на фон кнопки
    func setBackgroundColor(color: UIColor, forState: UIControlState) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.setBackgroundImage(colorImage, for: forState)
    }
    
    //функция для установки радиуса скругления угла
    func setCornerRadius(cornerRadius: CGFloat) {
        self.cornerRadius = cornerRadius
    }
    
}


