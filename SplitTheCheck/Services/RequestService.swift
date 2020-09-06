//
//  RequestService.swift
//  SplitTheCheck
//
//  Created by Anya on 12/01/2018.
//  Copyright © 2018 Anna Vondrukhova. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class RequestService {
    
    //проверяем существование чека
    static func checkExist(receivedString: String) {
        print ("existence check begin")
        
        //разбираем полученную строку на словарь с параметрами
        var params = receivedString
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
        
        let dateFormatter = DateFormatter()
        var oldDate = Date()
        dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss"
        if dateFormatter.date(from: params["t"]!) != nil {
            oldDate = dateFormatter.date(from: params["t"]!)!
        } else {
            dateFormatter.dateFormat = "yyyyMMdd'T'HHmm"
            if dateFormatter.date(from: params["t"]!) != nil {
                oldDate = dateFormatter.date(from: params["t"]!)!
            } else {
                NSLog ("receivedString: unknown date format")
            }
        }
        print(oldDate)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        params["t"] = dateFormatter.string(from: oldDate)
        
        
        params["s"] = "\(Int(round(Double(params["s"]!)!*100)))"
        print(params["s"]!)
        
        print(String(describing: params))
//
//        let url = URL(string: "https://proverkacheka.nalog.ru:9999/v1/ofds/*/inns/*/fss/9285000100026395/operations/1/tickets/19229?fiscalSign=1477567723&date=2019-01-07T18:10:00&sum=237463")
        let url = URL(string: "https://proverkacheka.nalog.ru:9999/v1/ofds/*/inns/*/fss/\(params["fn"]!)/operations/\(params["n"]!)/tickets/\(params["i"]!)?fiscalSign=\(params["fp"]!)&date=\(params["t"]!)&sum=\(params["s"]!)")
        
        print(String(describing: url))
        
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.timeoutInterval = 7
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                let qrStringItem = QrStringInfoObject(error: "\(000)", qrString: receivedString, jsonString: nil)
                RealmServices.saveQRString(string: qrStringItem)
                if error!._code == NSURLErrorTimedOut {
                    print("case .failure (timeout)\(error!.localizedDescription)")
                    NSLog("Check existence request: case failure (timeout) \(error!.localizedDescription)")
                }
                print("case .failure \(error!.localizedDescription)")
                NSLog("Check existence request: case failure \(error!.localizedDescription)")
                return
            }
            
            let httpResponse = response as? HTTPURLResponse
            
            //если ответ получен, то:
            if httpResponse != nil {
                let statusCode = httpResponse!.statusCode
                print("Status code = \(statusCode)")
                NSLog("Status code = \(statusCode)")
                
                if statusCode == 204 {
                    print("Check existence request: success, loading data")
                    RequestService.loadData(receivedString: receivedString)
                    print("Check existence request: success, loading data")
                    NSLog("Check existence request: success, loading data")
                }
                else {
                    let qrStringItem = QrStringInfoObject(error: "\(statusCode)", qrString: receivedString, jsonString: nil)
                    RealmServices.saveQRString(string: qrStringItem)
                    print("case error: \(statusCode)")
                    NSLog("Check existence request: case error \(statusCode)")
                }
            }
            else {
                let qrStringItem = QrStringInfoObject(error: "\(001)", qrString: receivedString, jsonString: nil)
                RealmServices.saveQRString(string: qrStringItem)
                if error!._code == NSURLErrorTimedOut {
                    print("case .failure (timeout)\(error!.localizedDescription)")
                    NSLog("Check existence request: case failure (timeout) \(error!.localizedDescription)")
                }
                print("case .failure \(error!.localizedDescription)")
                NSLog("Check existence request: case failure \(error!.localizedDescription)")
            }
        }
        
        task.resume()
    }
    
    //загружаем данные с сайта ФНС
    static func loadData(receivedString: String){
        print("loadData func begin")
        
        let user = UserDefaults.standard.string(forKey: "user")
        let password = UserDefaults.standard.string(forKey: "password")
        let loginData = String(format: "%@:%@", user!, password!).data(using: String.Encoding.utf8)!
        let base64LoginData = loginData.base64EncodedString()
        
//        let headers = ["Authorization": "Basic \(base64LoginData)", "Device-Id": "84EDF5AE-13AE-42ED-9164-D77189481489", "Device-OS": "iOS 11.2.2", "Version":"2", "ClientVersion":"1.4.2", "Host": "proverkacheka.nalog.ru:8888", "Connection":"keep-alive", "Accept-Language": "ru;q=1", "User-Agent": "okhttp/3.0.1"]
        
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
        
        let url = URL(string: "https://proverkacheka.nalog.ru:9999/v1/inns/*/kkts/*/fss/\(params["fn"]!)/tickets/\(params["i"]!)?fiscalSign=\(params["fp"]!)&sendToEmail=no")
        
//        let configuration = URLSessionConfiguration.default
//        configuration.timeoutIntervalForRequest = 7 // seconds
//        configuration.timeoutIntervalForResource = 7
//        let alamoFireManager = Alamofire.SessionManager(configuration: configuration)
        var request = URLRequest(url: url!)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic \(base64LoginData)", forHTTPHeaderField: "Authorization")
        request.setValue("", forHTTPHeaderField: "Device-Id")
        request.setValue("", forHTTPHeaderField: "Device-OS")
        request.httpMethod = "GET"
        request.timeoutInterval = 7
        
        AF.request(request).responseData { response in
                print ("Alamofire begin")
                NSLog ("Alamofire request: start")
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
                        NSLog("Alamofire request: case success")
                    }
                    //если json пустой, записываем строку в базу с jsonString = nil и error != nil
                    else {
                        let qrStringItem = QrStringInfoObject(error: "\(response.response?.statusCode ?? 500)", qrString: receivedString, jsonString: nil)
                        RealmServices.saveQRString(string: qrStringItem)
                        print("case error: \(String(describing: response.response?.statusCode))")
                        NSLog("Alamofire request: case error \(String(describing: response.response?.statusCode))")
                    }
                    
                //если не получили json, записываем строку в базу с jsonString = nil и error != nil
                case .failure (let error):
                    let qrStringItem = QrStringInfoObject(error: "\(response.response?.statusCode ?? 500)", qrString: receivedString, jsonString: nil)
                    RealmServices.saveQRString(string: qrStringItem)
                    if error._code == NSURLErrorTimedOut {
                        print("case .failure (timeout)\(error.localizedDescription)")
                        NSLog("Alamofire request: case failure (timeout) \(error.localizedDescription)")
                    }
                    print("case .failure \(error.localizedDescription)")
                    NSLog("Alamofire request: case failure \(error.localizedDescription)")
                }
            }
        
        print ("loadData func end")

    }
        
}
