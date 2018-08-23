//
//  LoadedCheckCell.swift
//  SplitTheCheck
//
//  Created by Anya on 22/01/2018.
//  Copyright © 2018 Anna Zhulidova. All rights reserved.
//

import UIKit
import SwiftyJSON

class LoadedCheckCell: UICollectionViewCell {
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var sum: UILabel!
    @IBOutlet weak var shop: UILabel!
    
    func configure(jsonString: String) {
        let json = JSON.init(parseJSON: jsonString)
        
        print(json["document"]["receipt"]["dateTime"].stringValue)
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let fullDate = dateFormatter.date(from: json["document"]["receipt"]["dateTime"].stringValue)
        print (fullDate as Any)
        

        dateFormatter.dateFormat = "yyyy.MM.dd"
        let date = dateFormatter.string(from: fullDate!)
        dateFormatter.dateFormat = "HH:mm"
        let time = dateFormatter.string(from: fullDate!)
        
        
        self.date.text = date+"  "+time
        self.shop.text = json["document"]["receipt"]["user"].stringValue
        self.sum.text = "\(json["document"]["receipt"]["totalSum"].doubleValue/100)"
    }
}
