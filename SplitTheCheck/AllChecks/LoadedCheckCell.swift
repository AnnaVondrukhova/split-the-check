//
//  LoadedCheckCell.swift
//  SplitTheCheck
//
//  Created by Anya on 22/01/2018.
//  Copyright © 2018 Anna Vondrukhova. All rights reserved.
//

import UIKit
import SwiftyJSON
@IBDesignable

class LoadedCheckCell: UITableViewCell {
    @IBOutlet weak var backColorView: UIView!
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var sum: UILabel!
    @IBOutlet weak var shop: UILabel!
    
    @IBInspectable var cornerRadius: CGFloat = 0{
        didSet{
            self.backColorView.layer.cornerRadius = cornerRadius
        }
    }
    
    var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "yyyy.MM.dd HH:mm"
        return df
    }
    
    func configure(jsonString: String) {
        self.selectionStyle = .none
        self.backColorView.layer.cornerRadius = 10
        
        let json = JSON.init(parseJSON: jsonString)
        
        let seconds = json["ticket"]["document"]["receipt"]["dateTime"].doubleValue
        print(seconds)
        let fullDate = Date(timeIntervalSince1970: seconds)

        print (fullDate as Any)

        self.date.text = dateFormatter.string(from: fullDate)
        
        let sellerName = json["seller"]["name"].stringValue.replacingOccurrences(of: " ", with: "")
        if sellerName != "" {
            self.shop.text = json["seller"]["name"].stringValue.replacingOccurrences(of: #"\""#, with: "\"")
        }
        else {
            self.shop.text = "Без названия"
        }
        self.sum.text = String(format: "%.2f", json["ticket"]["document"]["receipt"]["totalSum"].doubleValue/100)
    }
}
