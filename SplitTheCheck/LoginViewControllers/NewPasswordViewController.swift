//
//  NewPasswordViewController.swift
//  SplitTheCheck
//
//  Created by Anya on 26/07/2018.
//  Copyright © 2018 Anna Vondrukhova. All rights reserved.
//

import UIKit
import SwiftyJSON

class NewPasswordViewController: UIViewController {
    @IBOutlet weak var pwdText: UITextField!
    @IBOutlet weak var logInBtn: CustomButton!
    @IBOutlet weak var waitingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSLog ("NewPasswordVC did load")

        waitingView.layer.cornerRadius = 10
        waitingView.layer.opacity = 1
        self.activityIndicator.hidesWhenStopped = true
        pwdText.keyboardType = UIKeyboardType.numberPad
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        waitingView.isHidden = true
        NSLog ("NewPasswordVC will appear")
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }

    @IBAction func logIn(_ sender: Any) {
        logInBtn.backgroundColor = UIColor(red:0.75, green:0.75, blue:0.75, alpha:1.0)
        waitingView.isHidden = false
        activityIndicator.startAnimating()
        
        pwdText.endEditing(true)
        
        //при нажатии кнопки "Войти" пробуем авторизоваться
        let user = UserDefaults.standard.string(forKey: "user")!
        let password = pwdText.text!
        
        let url = URL(string: "https://proverkacheka.nalog.ru:9999/v1/mobile/users/login")
        
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        
        let loginData = String(format: "%@:%@", user, password).data(using: String.Encoding.utf8)!
        let base64LoginData = loginData.base64EncodedString()
        
        request.setValue("Basic \(base64LoginData)", forHTTPHeaderField: "Authorization")
        
        print ("\(user), \(password)")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "Unknown error")
                NSLog("guard: " + (error?.localizedDescription ?? "Unknown error"))
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.waitingView.isHidden = true
                    Alerts.showErrorAlert(VC: self, message: "Ошибка соединения с сервером")
                }
                return
            }
            
            let httpResponse = response as? HTTPURLResponse
            
            //если ответ получен, то:
            if httpResponse != nil {
                let statusCode = httpResponse!.statusCode
                print("Status code = \(statusCode)")
                NSLog("Status code = \(statusCode)")
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.waitingView.isHidden = true
                }
                
                if statusCode == 200 {
                    //если авторизация прошла, получаем имя и email пользователя, запоминаем, переходим на главную страницу приложения
                    let json = JSON(data)
                    let name = json["name"].stringValue
                    let email = json["email"].stringValue
                    
                    UserDefaults.standard.set(password, forKey: "password")
                    UserDefaults.standard.set(name, forKey: "name")
                    UserDefaults.standard.set(email, forKey: "email")
                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                    
                    DispatchQueue.main.async {
                        self.navigationController?.isNavigationBarHidden = true
                        self.performSegue(withIdentifier: "fromNewPasswordToCheckHistoryVC", sender: nil)
                    }
                }
                else if statusCode == 403 {
                    //если авторизация не прошла, выдаем ошибку
                    print ("thread \(Thread.isMainThread)")
                    DispatchQueue.main.async {
                        Alerts.showErrorAlert(VC: self, message: "Неверный пользователь или пароль")
                        self.logInBtn.backgroundColor = UIColor(red:0.37, green:0.75, blue:0.62, alpha:1.0)
                    }
                }
                else {
                    //при неизвестной ошибке выдаем ошибку соединения с сервером
                    print ("Unknown error, status code = \(statusCode), data = \(data), thread \(Thread.isMainThread)")
                    NSLog ("Unknown error, status code = \(statusCode), data = \(data)")
                    DispatchQueue.main.async {
                        Alerts.showErrorAlert(VC: self, message: "Ошибка соединения с сервером")
                    }
                }
            }
            else {
                print (httpResponse!.allHeaderFields)
                NSLog ("No status code: \(httpResponse!.allHeaderFields)")
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.waitingView.isHidden = true
                    Alerts.showErrorAlert(VC: self, message: "Ошибка соединения с сервером")
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
