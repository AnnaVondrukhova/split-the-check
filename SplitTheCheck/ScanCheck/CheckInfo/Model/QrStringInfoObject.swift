//
//  qrStringInfo.swift
//  SplitTheCheck
//
//  Created by Anya on 25/01/2018.
//  Copyright © 2018 Anna Vondrukhova. All rights reserved.
//

import Foundation
import RealmSwift

class QrStringInfoObject: Object {
    @objc dynamic var id = ""
    @objc dynamic var error: String?
    @objc dynamic var qrString = ""
    @objc dynamic var jsonString: String?
    var checkItems = List<CheckInfoObject>()
    @objc dynamic var checkDate: Date?
    @objc dynamic var mDate: Date?
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(error: String?, qrString: String, jsonString: String?) {
        self.init()
        
        self.error = error
        self.id = UserDefaults.standard.string(forKey: "user")! + qrString
        self.qrString = qrString
        self.jsonString = jsonString
        self.mDate = Date()
        print ("current date \(self.mDate!)")
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let start = qrString.index(qrString.startIndex, offsetBy: 2)
        var end = qrString.index(qrString.startIndex, offsetBy: 17)
        var range = start..<end
        if dateFormatter.date(from: String(qrString[range])) != nil {
            self.checkDate = dateFormatter.date(from: String(qrString[range]))
        } else {
            dateFormatter.dateFormat = "yyyyMMdd'T'HHmm"
            end = qrString.index(qrString.startIndex, offsetBy: 15)
            range = start..<end
            if dateFormatter.date(from: String(qrString[range])) != nil {
                self.checkDate = dateFormatter.date(from: String(qrString[range]))
            } else {
                NSLog ("QrStringInfoObject: unknown date format")
            }
        }
        
        print ("check date \(self.checkDate as Any)")
    }
    
    func addCheckItems(_ checkItems: [CheckInfoObject]) {
        self.checkItems.append(objectsIn: checkItems)
        
        
    }
}
