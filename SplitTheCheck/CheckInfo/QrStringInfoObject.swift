//
//  qrStringInfo.swift
//  SplitTheCheck
//
//  Created by Anya on 25/01/2018.
//  Copyright © 2018 Anna Zhulidova. All rights reserved.
//

import Foundation
import RealmSwift

class QrStringInfoObject: Object {
    @objc dynamic var error: String?
    @objc dynamic var qrString = ""
    @objc dynamic var jsonString: String?
    var checkItems = List<CheckInfoObject>()
    
    override static func primaryKey() -> String? {
        return "qrString"
    }
    
    convenience init(error: String?, qrString: String, jsonString: String?) {
        self.init()
        
        self.error = error
        self.qrString = qrString
        self.jsonString = jsonString
        
    }
    
    func addCheckItems(_ checkItems: [CheckInfoObject]) {
        self.checkItems.append(objectsIn: checkItems)
        
        
    }
}