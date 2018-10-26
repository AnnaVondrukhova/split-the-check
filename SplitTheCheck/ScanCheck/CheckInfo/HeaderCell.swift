//
//  HeaderCell.swift
//  SplitTheCheck
//
//  Created by Anya on 15/01/2018.
//  Copyright © 2018 Anna Zhulidova. All rights reserved.
//

import UIKit

class HeaderCell: UITableViewCell {

    @IBOutlet weak var totalSum: UILabel!
    @IBOutlet weak var sectionTitle: UIButton!
    @IBOutlet weak var foldBtn: CustomButton!
    
    var delegate: CheckInfoViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isUserInteractionEnabled = true
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
