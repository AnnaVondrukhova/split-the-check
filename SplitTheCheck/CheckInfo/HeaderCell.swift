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
    @IBOutlet weak var sectionTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
