//
//  LoadedCheckCell.swift
//  SplitTheCheck
//
//  Created by Anya on 22/01/2018.
//  Copyright © 2018 Anna Zhulidova. All rights reserved.
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
    
    
    
    func configure(jsonString: String) {
        self.selectionStyle = .none
        self.backColorView.layer.cornerRadius = 10
        
        let json = JSON.init(parseJSON: jsonString)
        
        print(json["document"]["receipt"]["dateTime"].stringValue)
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let fullDate = dateFormatter.date(from: json["document"]["receipt"]["dateTime"].stringValue)
        if fullDate == nil {
            NSLog ("LoadedCheckCell: something wrong with fullDate")
        }
        print (fullDate as Any)
        

        dateFormatter.dateFormat = "yyyy.MM.dd"
        let date = dateFormatter.string(from: fullDate!)
        dateFormatter.dateFormat = "HH:mm"
        let time = dateFormatter.string(from: fullDate!)
        
        
        self.date.text = date+"  "+time
        if json["document"]["receipt"]["user"].stringValue.replacingOccurrences(of: " ", with: "") != "" {
            self.shop.text = json["document"]["receipt"]["user"].stringValue.replacingOccurrences(of: " ", with: "", options: [.anchored], range: nil )
        }
        else {
            self.shop.text = "Без названия"
        }
        self.sum.text = String(format: "%.2f", json["document"]["receipt"]["totalSum"].doubleValue/100)
    }
}
