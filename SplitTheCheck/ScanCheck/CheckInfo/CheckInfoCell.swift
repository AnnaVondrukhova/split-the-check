//
//  ResultCell.swift
//  SplitTheCheck
//
//  Created by Anya on 12/01/2018.
//  Copyright © 2018 Anna Zhulidova. All rights reserved.
//

import UIKit

class CheckInfoCell: UITableViewCell {

    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemPrice: UILabel!
    @IBOutlet weak var itemAmount: CustomLabel!
    @IBOutlet weak var itemSum: UILabel!
    
    var delegate: CheckInfoViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        itemAmount.isUserInteractionEnabled = true
        itemAmount.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(labelAmountTapped(_:))))
        
        itemAmount.layer.cornerRadius = 7
        itemAmount.layer.borderWidth = 0
        itemAmount.layer.borderColor = UIColor(red:0.26, green:0.71, blue:0.56, alpha:1.0).cgColor
    }
    
    func configure(item: CheckInfoObject, section: Int) {
        itemName.text = item.name
        itemPrice.text = String(item.price)
        if item.isCountable {
            itemSum.text = String(format: "%.2f", round(100*item.totalQuantity*item.price)/100)
            if (item.totalQuantity != 1) && item.isSelected {
                print ("\(item.name) selected")
                itemAmount.text = item.myQtotalQ
                itemAmount.backgroundColor = UIColor.white
                itemAmount.layer.borderWidth = 1
            } else {
                print ("\(item.name) not selected")
                itemAmount.text = "\(Int(item.totalQuantity))"
                itemAmount.backgroundColor = nil
                itemAmount.layer.borderWidth = 0
            }
        } else {
            print ("\(item.name) not selected")
            itemAmount.text = "\(item.totalQuantity)"
            itemAmount.backgroundColor = nil
            itemAmount.layer.borderWidth = 0
            itemSum.text = String(item.sum)
        }
        
        if section == 0 {
            self.isUserInteractionEnabled = true
        } else {
            self.isUserInteractionEnabled = false
        }
    }
    
    @objc func labelAmountTapped(_ sender: UITapGestureRecognizer) {
        print("tapped")
        delegate?.amountTapped(self)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
