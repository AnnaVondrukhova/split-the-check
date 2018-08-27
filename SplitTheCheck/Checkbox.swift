//
//  Checkbox.swift
//  SplitTheCheck
//
//  Created by Anya on 21/08/2018.
//  Copyright © 2018 Anna Zhulidova. All rights reserved.
//

import UIKit
protocol CheckboxDelegate {
    func checked(_ checkbox: Checkbox)
}

class Checkbox: UIButton {
    // Images
    let checkedImage = UIImage(named: "cb_checked")! as UIImage
    let uncheckedImage = UIImage(named: "cb_unchecked")! as UIImage
    
    var delegate: CheckboxDelegate?
    // Bool property
    var isChecked: Bool = false {
        didSet{
            if isChecked == true {
                self.setImage(checkedImage, for: UIControlState.normal)
            } else {
                self.setImage(uncheckedImage, for: UIControlState.normal)
            }
        }
    }
    
    override func awakeFromNib() {
        self.addTarget(self, action:#selector(buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.isChecked = false
    }
    
    @objc func buttonClicked(sender: UIButton) {
        if sender == self {
            isChecked = !isChecked
            delegate?.checked(self)
        }
    }
}
