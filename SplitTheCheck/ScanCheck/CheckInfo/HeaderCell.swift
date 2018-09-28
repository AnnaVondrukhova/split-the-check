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
    
//    var isFolded = false {
//        didSet {
//            if isFolded {
//                self.foldBtn.setImage(UIImage(named: "folded"), for: .normal)
//            } else {
//                self.foldBtn.setImage(UIImage(named: "unfolded"), for: .normal)
//            }
//        }
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isUserInteractionEnabled = true
        // Initialization code
//        self.contentView.frame.size.height = 40
        
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
//
//    @IBAction func foldBtnTap(_ sender: UIButton) {
//        delegate?.cellFoldBtnTap(self)
//    }
    
}
