//
//  NetworkService.swift
//  SplitTheCheck
//
//  Created by Anya on 03.09.2020.
//  Copyright © 2020 Anna Zhulidova. All rights reserved.
//

import Foundation
import Foundation
import Alamofire
import SwiftyJSON

class NetworkService {
    static let shared = NetworkService()
    let uuid = UIDevice.current.identifierForVendor?.uuidString ?? "7C82010F-16CC-446B-8F66-FC4080C66521"
    let inn = UserDefaults.standard.object(forKey: "user") ?? ""
    let password = UserDefaults.standard.object(forKey: "password") ?? ""
    
    func getSessionId(completion: @escaping(String?, Error?, Int) -> ()) {
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            print(uuid)
        }
        let url = "https://irkkt-mobile.nalog.ru:8888/v2/mobile/users/lkfl/auth"
        let payload = ["inn": inn, "client_secret": "IyvrAbKt9h/8p6a7QPh8gpkXYQ4=", "password": password]
        
        
        let headers = ["Host": "irkkt-mobile.nalog.ru:8888",
                       "Accept": "*/*",
                       "Device-OS": "iOS",
                       "Device-Id": self.uuid,
                       "Accept-Language": "ru-RU;q=1, en-US;q=0.9",
                       "Content-Type": "application/json"]
        let httpHeaders = HTTPHeaders(headers)
        
        AF.request(url, method: .post, parameters: payload, encoding: JSONEncoding.default, headers: httpHeaders).responseJSON { (response) in
            let statusCode = response.response?.statusCode ?? 0
            print("getSessionId status code: ", statusCode)
            switch response.result {
            case .success(let value):
                if let json = value as? [String: Any] {
                    print("Session id: ", json["sessionId"] as? String ?? "no ID")
                    completion(json["sessionId"] as? String, nil, statusCode)
                }
                
            case .failure(let error):
                print("getSessionId error: ", error.localizedDescription)
                completion(nil, error, statusCode)
            }
        }
    }
    
    func getTicketId(qrString: String, completion: @escaping(String?, String?, Error?)->()) {
        getSessionId { (sessionId, error, statusCode) in
            guard let sessionId = sessionId, statusCode == 200, error == nil else {
                completion (nil, nil, error)
                return
            }
            
            let url = "https://irkkt-mobile.nalog.ru:8888/v2/ticket"
//            let qrString = "t=20200829T1109&s=1399.00&fn=9280440300724624&i=9202&fp=964283072&n=1"
//            let qrString = "t=20200525T1441&s=5449.15&fn=9289000100513986&i=43561&fp=1330867838&n=1"
            let payload = ["qr": qrString]
            let headers = ["Host": "irkkt-mobile.nalog.ru:8888",
                           "Accept": "*/*",
                           "Device-OS": "iOS",
                           "Device-Id": self.uuid,
                           "Accept-Language": "ru-RU;q=1, en-US;q=0.9",
                           "Content-Type": "application/json",
                           "sessionId": sessionId]
            let httpHeaders = HTTPHeaders(headers)
            
            AF.request(url, method: .post, parameters: payload, encoding: JSONEncoding.default, headers: httpHeaders).responseJSON { (response) in
                print(response)
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        print("Ticket id: ", json["id"] as? String ?? "no ID")
                        completion(sessionId, json["id"] as? String, nil)
                    }
                    
                case .failure(let error):
                    print("getTicketId error: ", error.localizedDescription)
                    completion(sessionId, nil, error)
                }
            }
        }
    }
    
    func getCheckInfo(receivedString: String) {
        getTicketId(qrString: receivedString) { (sessionId, ticketId, error) in
            guard let sessionId = sessionId, let ticketId = ticketId, error == nil else {
                let qrStringItem = QrStringInfoObject(error: "\(error?._code ?? 500)", qrString: receivedString, jsonString: nil)
                RealmServices.saveQRString(string: qrStringItem)
                if let error = error {
                    if error._code == NSURLErrorTimedOut {
                        print("Alamofire first check request: case failure (timeout) \(error.localizedDescription)")
                        NSLog("Alamofire first check request: case failure (timeout) \(error.localizedDescription)")
                    }
                }
                
                print("Alamofire first check request: case failure \(error?.localizedDescription)")
                NSLog("Alamofire first check request: case failure \(error?.localizedDescription)")
                return
            }
            
            let url = "https://irkkt-mobile.nalog.ru:8888/v2/tickets/\(ticketId)"
            let headers = ["Host": "irkkt-mobile.nalog.ru:8888",
                           "Accept": "*/*",
                           "Device-OS": "iOS",
                           "Device-Id": self.uuid,
                           "Accept-Language": "ru-RU;q=1, en-US;q=0.9",
                           "Content-Type": "application/json",
                           "sessionId": sessionId]
            let httpHeaders = HTTPHeaders(headers)
            
            AF.request(url, method: .get, encoding: JSONEncoding.default,  headers: httpHeaders).responseJSON { (response) in
                switch response.result {
                case .success(let value):
//                    print(value)
                    let json = JSON(value)
                    print (json)
                    print (json["ticket"].rawString())
                    if json["ticket"].rawString() == "null" {
                        print ("Alamofire first check request: case success, empty ticket")
                        NSLog("Alamofire first check request: case success, empty ticket")
                        sleep(1)
                        AF.request(url, method: .get, encoding: JSONEncoding.default,  headers: httpHeaders).responseJSON { (response) in
                            switch response.result {
                            case .success(let value):
                                let json = JSON(value)
                                print(json)
                                if json.rawString() != "null" {
                                    let qrStringItem = QrStringInfoObject(error: nil, qrString: receivedString, jsonString: json.rawString())
                                    let check = json["ticket"]["document"]["receipt"]["items"].compactMap {CheckInfoObject(json: $0.1)}
                                    qrStringItem.addCheckItems(check)
                                    RealmServices.saveQRString(string: qrStringItem)
                                    print ("Alamofire repeat check request: case success")
                                    NSLog("Alamofire repeat check request: case success")
                                }
                                //если json пустой, записываем строку в базу с jsonString = nil и error != nil
                                else {
                                    let qrStringItem = QrStringInfoObject(error: "\(response.response?.statusCode ?? 500)", qrString: receivedString, jsonString: nil)
                                    RealmServices.saveQRString(string: qrStringItem)
                                    print("Alamofire repeat check request: case error \(String(describing: response.response?.statusCode))")
                                    NSLog("Alamofire repeat check request: case error \(String(describing: response.response?.statusCode))")
                                }
                            case .failure(let error):
                                let qrStringItem = QrStringInfoObject(error: "\(error._code)", qrString: receivedString, jsonString: nil)
                                RealmServices.saveQRString(string: qrStringItem)
                                if error._code == NSURLErrorTimedOut {
                                    print("Alamofire repeat check request: case failure (timeout) \(error.localizedDescription)")
                                    NSLog("Alamofire repeat check request: case failure (timeout) \(error.localizedDescription)")
                                }
                                print("Alamofire repeat check request: case failure \(error.localizedDescription)")
                                NSLog("Alamofire repeat check request: case failure \(error.localizedDescription)")
                            }
                        }
                    } else {
                        let qrStringItem = QrStringInfoObject(error: nil, qrString: receivedString, jsonString: json.rawString())
                        let check = json["ticket"]["document"]["receipt"]["items"].compactMap {CheckInfoObject(json: $0.1)}
                        qrStringItem.addCheckItems(check)
                        RealmServices.saveQRString(string: qrStringItem)
                        print ("Alamofire first check request: case success, got ticket")
                        NSLog("Alamofire first check request: case success, got ticket")
                    }
                case .failure(let error):
                    let qrStringItem = QrStringInfoObject(error: "\(error._code)", qrString: receivedString, jsonString: nil)
                    RealmServices.saveQRString(string: qrStringItem)
                    if error._code == NSURLErrorTimedOut {
                        print("Alamofire first check request: case failure (timeout) \(error.localizedDescription)")
                        NSLog("Alamofire first check request: case failure (timeout) \(error.localizedDescription)")
                    }
                    print("Alamofire first check request: case failure \(error.localizedDescription), \(error._code)")
                    NSLog("Alamofire first check request: case failure \(error.localizedDescription)")
                }
            }
        }
    }
}
