//
//  RealmServices.swift
//  SplitTheCheck
//
//  Created by Anya on 29/08/2018.
//  Copyright © 2018 Anna Zhulidova. All rights reserved.
//

import Foundation
import RealmSwift

class RealmServices {
    
    //сохраняем наш объект QrStringInfo в базу данных
    static func saveQRString(string: QrStringInfoObject) {
        do {
            //            Realm.Configuration.defaultConfiguration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
            //            print("configuration changed")
            let realm = try Realm()
            realm.beginWrite()
            realm.add(string, update: true)
            print ("added string to Realm")
            try realm.commitWrite()
            print(realm.configuration.fileURL as Any)
        } catch {
            print(error)
        }
    }
    
    

}
