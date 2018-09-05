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

class RequestService {
    
    //загружаем данные с сайта ФНС
    static func loadData(receivedString: String){
        print("loadData func begin")
        
        let user = UserDefaults.standard.string(forKey: "user")
        let password = UserDefaults.standard.string(forKey: "password")
        let loginData = String(format: "%@:%@", user!, password!).data(using: String.Encoding.utf8)!
        let base64LoginData = loginData.base64EncodedString()
        
        let headers = ["Authorization": "Basic \(base64LoginData)", "Device-Id": "84EDF5AE-13AE-42ED-9164-D77189481489", "Device-OS": "iOS 11.2.2", "Version":"2", "ClientVersion":"1.4.2", "Host": "proverkacheka.nalog.ru:8888", "Connection":"keep-alive", "Accept-Language": "ru;q=1", "User-Agent": "okhttp/3.0.1"]
        
        //разбираем полученную строку на словарь с параметрами
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
        
        let url = "https://proverkacheka.nalog.ru:9999/v1/inns/*/kkts/*/fss/\(params["fn"]!)/tickets/\(params["i"]!)?fiscalSign=\(params["fp"]!)&sendToEmail=no"
                
            Alamofire.request(url, method: .get, headers: headers).validate(statusCode: 200..<600).responseData { response in
                print ("Alamofire begin")
                switch response.result {
                //если получили json, записываем строку в базу с jsonString != nil
                case .success(let value):
                    let json = JSON(value)
                    if json.rawString() != "null" {
                        let qrStringItem = QrStringInfoObject(error: nil, qrString: receivedString, jsonString: json.rawString())
                        let check = json["document"]["receipt"]["items"].compactMap {CheckInfoObject(json: $0.1)}
                        qrStringItem.addCheckItems(check)
                        RealmServices.saveQRString(string: qrStringItem)
                        print ("case success")
                    } else {
                        let qrStringItem = QrStringInfoObject(error: "\(response.response?.statusCode ?? 500)", qrString: receivedString, jsonString: nil)
                        RealmServices.saveQRString(string: qrStringItem)
                        print("case error: \(String(describing: response.response?.statusCode))")
                    }
                    
                //если не получили json, записываем строку в базу с jsonString = nil и error != nil
                case .failure:
                    let qrStringItem = QrStringInfoObject(error: "\(response.response?.statusCode ?? 500)", qrString: receivedString, jsonString: nil)
                    RealmServices.saveQRString(string: qrStringItem)
                    print("case .failure \(String(describing: response.response?.statusCode))")
                }
            }
        
        print ("loadData func end")

    }
    
}
