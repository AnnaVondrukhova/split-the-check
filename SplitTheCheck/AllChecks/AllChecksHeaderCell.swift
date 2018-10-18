//
//  AllChecksHeaderCell.swift
//  SplitTheCheck
//
//  Created by Anya on 26/09/2018.
//  Copyright © 2018 Anna Zhulidova. All rights reserved.
//

import UIKit

class AllChecksHeaderCell: UITableViewCell {
        
    @IBOutlet weak var yearMonthLabel: UILabel!
    
    let months: [Int: String] = [1:"Январь", 2: "Февраль", 3: "Март",
                                 4: "Апрель", 5: "Май", 6:"Июнь",
                                 7:"Июль", 8: "Август", 9: "Сентябрь",
                                 10:"Октябрь", 11: "Ноябрь", 12: "Декабрь"]
    
    func configure (date: YearMonth) {
        let blurEffect = UIBlurEffect(style: .extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        self.backgroundView = blurEffectView
        self.yearMonthLabel.text = months[date.month]! + " \(date.year)"
    }
}
