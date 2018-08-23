//
//  RequestService.swift
//  SplitTheCheck
//
//  Created by Anya on 12/01/2018.
//  Copyright © 2018 Anna Zhulidova. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import RealmSwift

class RequestService {
    let user = UserDefaults.standard.string(forKey: "user")
    let password = UserDefaults.standard.string(forKey: "password")
    
    func loadData(receivedString: String){
        print("loadData func begin")
        
        let loginData = String(format: "%@:%@", user!, password!).data(using: String.Encoding.utf8)!
        let base64LoginData = loginData.base64EncodedString()
        
        let headers = ["Authorization": "Basic \(base64LoginData)", "Device-Id": "84EDF5AE-13AE-42ED-9164-D77189481489", "Device-OS": "iOS 11.2.2", "Version":"2", "ClientVersion":"1.4.2", "Host": "proverkacheka.nalog.ru:8888", "Connection":"keep-alive", "Accept-Language": "ru;q=1", "User-Agent": "okhttp/3.0.1"]
        
        let params = receivedString
            .components(separatedBy: "&")
            .map { $0.components(separatedBy: "=") }
            .reduce([String: String]()) { result, param in
                var dict = result
                let key = param[0]
                let value = param[1]
                dict[key] = value
                return dict
        }
        
        print ("params loaded")
        
        let url = "http://proverkacheka.nalog.ru:8888/v1/inns/*/kkts/*/fss/\(params["fn"]!)/tickets/\(params["i"]!)?sendToEmail=no&fiscalSign=\(params["fp"]!)"
        
            Alamofire.request(url, method: .get, headers: headers).validate(statusCode: 200..<600).responseData { response in
                print ("Alamofire begin")
                switch response.result {
                //если получили json, записываем строку в базу с jsonString != nil
                case .success(let value):
                    let json = JSON(value)
                    if json.rawString() != "null" {
                        let qrStringItem = QrStringInfo(error: nil, qrString: receivedString, jsonString: json.rawString())
                        let check = json["document"]["receipt"]["items"].flatMap {CheckInfo(json: $0.1)}
                        qrStringItem.addCheckItems(check)
                        self.saveQRString(string: qrStringItem)
                        print ("case success")
                    } else {
                        let qrStringItem = QrStringInfo(error: "No data received", qrString: receivedString, jsonString: nil)
                        self.saveQRString(string: qrStringItem)
                        print("case error: \(String(describing: json.rawString()))")
                    }
                    
                //если не получили json, записываем строку в базу с jsonString = nil и error != nil
                case .failure(let error):
                    let qrStringItem = QrStringInfo(error: error.localizedDescription, qrString: receivedString, jsonString: nil)
                    self.saveQRString(string: qrStringItem)
                    print("case error \(error)")
                }
            }
        
        print ("loadData func end")

    }
    
    func saveQRString(string: QrStringInfo) {
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
