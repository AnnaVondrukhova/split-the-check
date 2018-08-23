//
//  FavouriteGuestCell.swift
//  SplitTheCheck
//
//  Created by Anya on 17/01/2018.
//  Copyright © 2018 Anna Zhulidova. All rights reserved.
//

import UIKit

class FavouriteGuestCell: UITableViewCell {
    @IBOutlet weak var guestName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        guestName.font = UIFont.boldSystemFont(ofSize: 17)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
