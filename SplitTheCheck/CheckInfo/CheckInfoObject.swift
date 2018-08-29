//
//  CheckInfo.swift
//  SplitTheCheck
//
//  Created by Anya on 12/01/2018.
//  Copyright © 2018 Anna Zhulidova. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

class CheckInfoObject: Object {
    @objc dynamic var sectionId = 0
    @objc dynamic var sectionName = "Общий чек"
    @objc dynamic var id = 0
    @objc dynamic var name = ""
    @objc dynamic var initialQuantity = 0.0
    @objc dynamic var totalQuantity = 0.0
    @objc dynamic var price = 0.0
    @objc dynamic var myQuantity = 0
    @objc dynamic var myQtotalQ = ""
    var parent = LinkingObjects(fromType: QrStringInfoObject.self, property: "checkItems")
    
    static var classId = 1
    
    convenience init(json: JSON) {
        self.init()
        
        self.id = CheckInfoObject.classId
        self.name = json["name"].stringValue
        self.initialQuantity = json["quantity"].doubleValue
        self.totalQuantity = json["quantity"].doubleValue
        self.price = json["price"].doubleValue/100
//        self.myQuantity = json["quantity"].intValue
        self.myQtotalQ = json["quantity"].stringValue
        
        CheckInfoObject.classId += 1
        print ("id = \(id)")
    }
    
    convenience init (sectionId: Int, sectionName: String, id: Int, name: String, initialQuantity: Double, totalQuantity: Double, price: Double) {
        self.init()
        
        self.sectionId = sectionId
        self.sectionName = sectionName
        self.id = id
        self.name = name
        self.initialQuantity = initialQuantity
        self.totalQuantity = totalQuantity
        self.price = price
        self.myQuantity = 0
        self.myQtotalQ = "\(Int(totalQuantity))"
        
    }
    
    static func ==(lhs: CheckInfoObject, rhs: CheckInfoObject) -> Bool {
        return(lhs.id == rhs.id
        && lhs.name == rhs.name
        && lhs.initialQuantity == rhs.initialQuantity
        && lhs.price == rhs.price)
//        return lhs === rhs
    }
    
//    func encode(with aCoder: NSCoder) {
//        aCoder.encode(id, forKey: "id")
//        aCoder.encode(name, forKey: "name")
//        aCoder.encode(initialQuantity, forKey: "initialQuantity")
//        aCoder.encode(totalQuantity, forKey: "totalQuantity")
//        aCoder.encode(price, forKey: "price")
//        aCoder.encode(myQuantity, forKey: "myQuantity")
//        aCoder.encode(myQtotalQ, forKey: "myQtotalQ")
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        self.id = aDecoder.decodeInteger(forKey: "id")
//        self.name = aDecoder.decodeObject(forKey: "name") as! String
//        self.initialQuantity = aDecoder.decodeDouble(forKey: "initialQuantity")
//        self.totalQuantity = aDecoder.decodeDouble(forKey: "totalQuantity")
//        self.price = aDecoder.decodeDouble(forKey: "price")
//        self.myQuantity = aDecoder.decodeInteger(forKey: "myQuantity")
//        self.myQtotalQ = aDecoder.decodeObject(forKey: "myQtotalQ") as! String
//    }
    
    func printInfo() {
        print(" id: \(id) \n name: \(name),\n initialQuantity: \(initialQuantity) \n totalQuantity: \(totalQuantity) \n price: \(price)")
    }
    
    func copyItem() -> CheckInfoObject {
        let copy = CheckInfoObject(sectionId: sectionId, sectionName: sectionName, id: id, name: name, initialQuantity: initialQuantity, totalQuantity: totalQuantity, price: price)
        return copy
    }

}

