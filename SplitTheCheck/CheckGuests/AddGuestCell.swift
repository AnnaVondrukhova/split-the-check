//
//  AddGuestCell.swift
//  SplitTheCheck
//
//  Created by Anya on 17/01/2018.
//  Copyright © 2018 Anna Zhulidova. All rights reserved.
//

import UIKit

protocol addGuestDelegate {
    func addNewGuest (_ cell: AddGuestCell)
//    func addToFavourites (_ cell: AddGuestCell)
}

class AddGuestCell: UITableViewCell {
    @IBOutlet weak var guestName: UITextField!
    @IBOutlet weak var addGuestBtn: UIButton!
    
    
    var delegate: addGuestDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func addGuestBtnTap(_ sender: CustomButton) {
        delegate?.addNewGuest(self)
        print ("+ pressed")
    }
//    @IBAction func addToFavouritesBtnTap(_ sender: CustomButton) {
//        delegate?.addToFavourites(self)
//        print ("star pressed")
//    }
}
