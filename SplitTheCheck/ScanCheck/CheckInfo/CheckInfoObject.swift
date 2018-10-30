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
    @objc dynamic var sectionName = "Не распределено"
    @objc dynamic var id = 0
    @objc dynamic var name = ""
    @objc dynamic var initialQuantity = 0.0
    @objc dynamic var totalQuantity = 0.0
    @objc dynamic var isCountable = true
    @objc dynamic var price = 0.0
    @objc dynamic var myQuantity = 0
    @objc dynamic var myQtotalQ = ""
    @objc dynamic var sum = 0.0
    var parent = LinkingObjects(fromType: QrStringInfoObject.self, property: "checkItems")
    
    @objc dynamic var isSelected = false
    static var classId = 1
    
    override static func ignoredProperties() -> [String] {
        return ["isSelected"]
    }
    
    convenience init(json: JSON) {
        self.init()
        
        self.id = CheckInfoObject.classId
        self.name = json["name"].stringValue
        self.initialQuantity = json["quantity"].doubleValue
        self.totalQuantity = json["quantity"].doubleValue
        self.price = json["price"].doubleValue/100
//        self.myQuantity = json["quantity"].intValue
//        self.myQtotalQ = json["quantity"].stringValue
        if self.totalQuantity != Double(Int(self.totalQuantity)) {
            self.myQtotalQ = "\(self.totalQuantity)"
            self.isCountable = false
        } else {
            self.myQtotalQ = "\(Int(self.totalQuantity))"
            self.isCountable = true
        }

        self.sum = json["sum"].doubleValue/100
        
        CheckInfoObject.classId += 1
        print ("id = \(id)")
    }
    
    convenience init (sectionId: Int, sectionName: String, id: Int, name: String, initialQuantity: Double, totalQuantity: Double, isCountable: Bool, price: Double, sum: Double) {
        self.init()
        
        self.sectionId = sectionId
        self.sectionName = sectionName
        self.id = id
        self.name = name
        self.initialQuantity = initialQuantity
        self.totalQuantity = totalQuantity
        self.price = price
        self.myQuantity = 0
        //если totalQuantity - не целое значение, отображаем его не целым
        //если totalQuantity - целое значение, отображаем его без нулей
        if totalQuantity != Double(Int(totalQuantity)) {
            self.myQtotalQ = "\(totalQuantity)"
        } else {
            self.myQtotalQ = "\(Int(totalQuantity))"
        }
        self.isCountable = isCountable
        self.sum = round(sum)/100
        
    }
    
    static func ==(lhs: CheckInfoObject, rhs: CheckInfoObject) -> Bool {
        return(lhs.id == rhs.id
        && lhs.name == rhs.name
        && lhs.initialQuantity == rhs.initialQuantity
        && lhs.price == rhs.price)
//        return lhs === rhs
    }
    
    func printInfo() {
        print(" id: \(id) \n name: \(name),\n initialQuantity: \(initialQuantity) \n totalQuantity: \(totalQuantity) \n price: \(price)")
    }
    
    func copyItem() -> CheckInfoObject {
        let copy = CheckInfoObject(sectionId: sectionId, sectionName: sectionName, id: id, name: name, initialQuantity: initialQuantity, totalQuantity: totalQuantity, isCountable: isCountable, price: price, sum: sum*100)
        return copy
    }

}

