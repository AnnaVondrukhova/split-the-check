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
    @IBOutlet weak var itemAmount: UILabel!
    @IBOutlet weak var itemSum: UILabel!
    
    var delegate: CheckInfoViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        itemAmount.isUserInteractionEnabled = true
        itemAmount.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(labelAmountTapped(_:))))
    }
    
    func configure(item: CheckInfoObject, section: Int) {
        itemName.text = item.name
        itemPrice.text = String(item.price)
        itemAmount.text = item.myQtotalQ
        if item.isCountable {
            itemSum.text = String(format: "%.2f", round(100*item.totalQuantity*item.price)/100)
        } else {
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
        
//        itemAmount.text = String((itemAmount.text! as NSString).intValue % Int32(itemAmount.tag)+1)+"/\(itemAmount.tag)"
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
