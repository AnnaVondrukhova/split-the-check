//
//  GuestInfo.swift
//  SplitTheCheck
//
//  Created by Anya on 17/01/2018.
//  Copyright © 2018 Anna Vondrukhova. All rights reserved.
//

import Foundation
import RealmSwift

class User: Object {
    @objc dynamic var id = UserDefaults.standard.string(forKey: "user")
    var guests = List<GuestInfoObject>()
    var checks = List<QrStringInfoObject>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(id: String) {
        self.init()
        self.id = id
    }
    
}

class GuestInfoObject: Object {
    
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var name = ""
//    @objc dynamic var favourite = false
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(name: String) {
        self.init()
        
        self.name = name
        print ("new id = " + self.id)
    }
    
//    func encode(with aCoder: NSCoder) {
//        aCoder.encode(name, forKey: "name")
//        aCoder.encode(favourite, forKey: "favourite")
//
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        self.name = aDecoder.decodeObject(forKey: "name") as! String
//        self.favourite = aDecoder.decodeBool(forKey: "favourite")
//    }
}
