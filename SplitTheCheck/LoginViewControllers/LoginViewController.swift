//
//  LoginViewController.swift
//  SplitTheCheck
//
//  Created by Anya on 16/07/2018.
//  Copyright © 2018 Anna Zhulidova. All rights reserved.
//

import UIKit
import SwiftyJSON

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var loginText: UITextField!
    @IBOutlet weak var pwdText: UITextField!
    @IBOutlet weak var forgetBtn: UIButton!
    @IBOutlet weak var logInBtn: CustomButton!
    @IBOutlet weak var signUpBtn: CustomButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print ("LoginVC did load")
        
        self.activityIndicator.isHidden = true
        self.loginText.delegate = self
        loginText.keyboardType = UIKeyboardType.numberPad
        pwdText.keyboardType = UIKeyboardType.numberPad
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print ("did begin editing")
        if ((textField == loginText)&&(textField.text == "")) {
            print ("+7")
            textField.text = "+7"
        }
    }

    @IBAction func logIn(_ sender: Any) {
        logInBtn.backgroundColor = UIColor(red:0.75, green:0.75, blue:0.75, alpha:1.0)
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        loginText.endEditing(true)
        pwdText.endEditing(true)
        
        //при нажатии кнопки "Войти" пробуем авторизоваться
        let user = loginText.text ?? ""
        let password = pwdText.text ?? ""
        
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
                DispatchQueue.main.async {
                    self.activityIndicator.isHidden = true
                    self.activityIndicator.stopAnimating()
                    Alerts.showErrorAlert(VC: self, message: "Ошибка соединения с сервером")
                }
                return
            }
            
            let httpResponse = response as? HTTPURLResponse
            
            //если ответ получен, то:
            if httpResponse != nil {
                let statusCode = httpResponse!.statusCode
                print("Status code = \(statusCode)")
                DispatchQueue.main.async {
                    self.activityIndicator.isHidden = true
                    self.activityIndicator.stopAnimating()
                }
                
                if statusCode == 200 {
                    //если авторизация прошла, получаем имя и email пользователя, запоминаем, переходим на главную страницу приложения
                    let json = JSON(data)
                    let name = json["name"].stringValue
                    let email = json["email"].stringValue
                    
                    UserDefaults.standard.set(user, forKey: "user")
                    UserDefaults.standard.set(password, forKey: "password")
                    UserDefaults.standard.set(name, forKey: "name")
                    UserDefaults.standard.set(email, forKey: "email")
                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                    
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "fromLoginToCheckHistoryVC", sender: nil)
                    }
                }
                else if statusCode == 403 {
                    //если авторизация не прошла, выдаем ошибку
                    print ("thread \(Thread.isMainThread)")
                    DispatchQueue.main.async {
                        Alerts.showErrorAlert(VC: self, message: "Неверный пользователь или пароль")
                    }
                }
                else {
                    //при неизвестной ошибке выдаем ошибку соединения с сервером
                    print ("Unknown error, status code = \(statusCode), data = \(data), thread \(Thread.isMainThread)")
                    DispatchQueue.main.async {
                        Alerts.showErrorAlert(VC: self, message: "Ошибка соединения с сервером")
                    }
                }
            }
            else {
                print (httpResponse!.allHeaderFields)
                DispatchQueue.main.async {
                    self.activityIndicator.isHidden = true
                    self.activityIndicator.stopAnimating()
                    Alerts.showErrorAlert(VC: self, message: "Ошибка соединения с сервером")
                }
            }
        }
        
        task.resume()
        self.logInBtn.backgroundColor = UIColor(red:0.37, green:0.75, blue:0.62, alpha:1.0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
