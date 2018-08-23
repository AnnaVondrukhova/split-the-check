//
//  StartViewController.swift
//  SplitTheCheck
//
//  Created by Anya on 14/07/2018.
//  Copyright © 2018 Anna Zhulidova. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class StartViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("StartView did load")
        
        //Тестовый блок - УДАЛИТЬ
//        let domain = Bundle.main.bundleIdentifier!
//        UserDefaults.standard.removePersistentDomain(forName: domain)
        
//        print ("UserDefaults cleared")
        //

    }
    
    //проверка на автоматический вход в приложение
    override func viewDidAppear(_ animated: Bool) {
        //запрос на авторизацию
        let user = UserDefaults.standard.string(forKey: "user") ?? ""
        let password = UserDefaults.standard.string(forKey: "password") ?? ""
            
        let url = URL(string: "https://proverkacheka.nalog.ru:9999/v1/mobile/users/login")
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
            
        let loginData = String(format: "%@:%@", user, password).data(using: String.Encoding.utf8)!
        let base64LoginData = loginData.base64EncodedString()
            
        request.setValue("Basic \(base64LoginData)", forHTTPHeaderField: "Authorization")
            
        print ("\(user), \(password)")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "unknown error")
                print ("error: Go to LoginViewController")
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "toLoginVC", sender: nil)
                }
                return
            }
            
            //если ответ получен, то:
            if let httpResponse = response as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode
                print("Status code = \(statusCode)")

                //если авторизация прошла, переходим на главную страницу приложения
                if statusCode == 200 {
                    let json = JSON(data)
                    print (json.description)
                    print ("thread \(Thread.isMainThread)")
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "toCheckHistoryVC", sender: nil)
                    }
                }
                else {
                    //если авторизация не прошла, переходим на страницу логина
                    print ("thread \(Thread.isMainThread)")
                    print ("Go to LoginViewController")
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "toLoginVC", sender: nil)
                    }
                }
            }
        }
            
        task.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
