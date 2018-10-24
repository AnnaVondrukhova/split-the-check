//
//  NotLoadedCheckCell.swift
//  SplitTheCheck
//
//  Created by Anya on 22/01/2018.
//  Copyright © 2018 Anna Zhulidova. All rights reserved.
//

import UIKit
@IBDesignable

class NotLoadedCheckCell: UITableViewCell {
    @IBOutlet weak var backColorView: UIView!
    @IBOutlet weak var qrImage: UIImageView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var sum: UILabel!
    
    @IBInspectable var cornerRadius: CGFloat = 0{
        didSet{
            self.layer.cornerRadius = cornerRadius
        }
    }

    
    func configure (qrString: String) {
        self.selectionStyle = .none
        self.backColorView.layer.cornerRadius = 10
        
        let fullDate: Date?
        let params = qrString
            .components(separatedBy: "&")
            .map { $0.components(separatedBy: "=") }
            .reduce([String: String]()) { result, param in
                var dict = result
                let key = param[0]
                let value = param[1]
                dict[key] = value
                return dict
        }
        
        print (params["t"])
        NSLog ("params[t] = \(params["t"])")
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        if dateFormatter.date(from: params["t"]!) != nil {
            fullDate = dateFormatter.date(from: params["t"]!)
        } else {
            dateFormatter.dateFormat = "yyyyMMdd'T'HHmm"
            fullDate = dateFormatter.date(from: params["t"]!)
        }
        print (fullDate as Any)
        
        
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let date = dateFormatter.string(from: fullDate!)
        dateFormatter.dateFormat = "HH:mm"
        let time = dateFormatter.string(from: fullDate!)
        
        self.date.text = date+"  "+time
        self.sum.text = params["s"]
//        self.qrImage.image = UIImage(named: "qrCode")
    }
}
