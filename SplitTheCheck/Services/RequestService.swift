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
        
//        var request = URLRequest(url: url!)
//        request.httpMethod = "GET"
//        request.allHTTPHeaderFields = headers
//
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            guard let data = data, error == nil else {
//                print(error?.localizedDescription ?? "Unknown error")
//                DispatchQueue.main.async {
//                    Alerts.showErrorAlert(VC: self, message: "Ошибка соединения с сервером")
//                }
//                return
//            }
//
//            let httpResponse = response as? HTTPURLResponse
//
//            //если ответ получен, то:
//            if httpResponse != nil {
//                let statusCode = httpResponse!.statusCode
//                print("Status code = \(statusCode)")
//
//                if statusCode == 200 {
//                    //если авторизация прошла, получаем имя и email пользователя, запоминаем, переходим на главную страницу приложения
//                    let json = JSON(data)
//                    if json.rawString() != "null" {
//                        let qrStringItem = QrStringInfoObject(error: nil, qrString: receivedString, jsonString: json.rawString())
//                        let check = json["document"]["receipt"]["items"].compactMap {CheckInfoObject(json: $0.1)}
//                        qrStringItem.addCheckItems(check)
//                        RealmServices.saveQRString(string: qrStringItem)
//                        print ("case success")
//                    } else {
//                        let qrStringItem = QrStringInfoObject(error: "No data received", qrString: receivedString, jsonString: nil)
//                        RealmServices.saveQRString(string: qrStringItem)
//                        print("case error: \(String(describing: json.rawString()))")
//                    }
//                }
//                else if statusCode == 202 {
//                    //если перед вызовом данного метода не происходила проверка существования чека, повторно делаем запрос
//                    loadData(receivedString: receivedString)
//                }
//                else if statusCode == 403 {
//                    //если авторизация не прошла, выдаем ошибку
//                    print ("Unknown error, status code = \(statusCode), data = \(data), thread \(Thread.isMainThread)")
//                    let qrStringItem = QrStringInfoObject(error: error.localizedDescription, qrString: receivedString, jsonString: nil)
//                    RealmServices.saveQRString(string: qrStringItem)
//
//                    DispatchQueue.main.async {
//                        Alerts.showErrorAlert(VC: self, message: "Неверный пользователь или пароль")
//                    }
//                }
//                else if statusCode == 406 {
//                    //если чек не найден, выдаем ошибку
//                    print ("Unknown error, status code = \(statusCode), data = \(data), thread \(Thread.isMainThread)")
//                    let qrStringItem = QrStringInfoObject(error: error.localizedDescription, qrString: receivedString, jsonString: nil)
//                    RealmServices.saveQRString(string: qrStringItem)
//
//                    DispatchQueue.main.async {
//                        Alerts.showErrorAlert(VC: self, message: "Чек не найден")
//                    }
//                }
//                else {
//                    //при неизвестной ошибке выдаем ошибку соединения с сервером
//                    print ("Unknown error, status code = \(statusCode), data = \(data), thread \(Thread.isMainThread)")
//                    let qrStringItem = QrStringInfoObject(error: error.localizedDescription, qrString: receivedString, jsonString: nil)
//                    RealmServices.saveQRString(string: qrStringItem)
//
//                    DispatchQueue.main.async {
//                        Alerts.showErrorAlert(VC: self, message: "Ошибка соединения с сервером")
//                    }
//                }
//            }
//            else {
//                print ("Unknown error, status code = \(statusCode), data = \(data), thread \(Thread.isMainThread)")
//                let qrStringItem = QrStringInfoObject(error: error.localizedDescription, qrString: receivedString, jsonString: nil)
//                RealmServices.saveQRString(string: qrStringItem)
//
//                DispatchQueue.main.async {
//                    Alerts.showErrorAlert(VC: self, message: "Ошибка соединения с сервером")
//                }
//            }
//        }
//
//        task.resume()
//        self.logInBtn.backgroundColor = UIColor(red:0.37, green:0.75, blue:0.62, alpha:1.0)
//    }

        
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
                    print("case error \(String(describing: response.response?.statusCode))")
                }
            }
        
        print ("loadData func end")

    }
    
}
