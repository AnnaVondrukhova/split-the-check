//
//  SignUpViewController.swift
//  SplitTheCheck
//
//  Created by Anya on 17/07/2018.
//  Copyright © 2018 Anna Zhulidova. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var telText: UITextField!
    @IBOutlet weak var checkbox: Checkbox!
    @IBOutlet weak var agreementBtn: UIButton!
    @IBOutlet weak var signUpBtn: CustomButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.activityIndicator.isHidden = true
        self.telText.delegate = self
        telText.keyboardType = UIKeyboardType.numberPad
//        agreementBtn.titleLabel?.attributedText = NSAttributedString(string: (agreementBtn.titleLabel?.text!)!, attributes: [.underlineStyle: NSUnderlineStyle.styleSingle.rawValue])
        signUpBtn.isEnabled = false
        signUpBtn.backgroundColor = UIColor(red:0.75, green:0.75, blue:0.75, alpha:1.0)
        checkbox.delegate = self
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        print ("did begin editing")
        if telText.text == "" {
            print ("+7")
            telText.text = "+7"
        }
    }
    
    @IBAction func signUp(_ sender: Any) {
        //регистрируем пользователя
        signUpBtn.backgroundColor = UIColor(red:0.75, green:0.75, blue:0.75, alpha:1.0)
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        let name = nameText.text ?? ""
        let email = emailText.text ?? ""
        let tel = telText.text ?? ""
        
        let url = URL(string: "https://proverkacheka.nalog.ru:9999/v1/mobile/users/signup")
        
        var request = URLRequest(url: url!)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let headers = ["email":email,"name":name,"phone":tel]
        request.httpBody = try! JSONSerialization.data(withJSONObject: headers)
        
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
                
                if statusCode == 204 {
                    print ("New password was sent")
                    //запоминаем имя, email и телефон-логин
                    UserDefaults.standard.set(name, forKey: "name")
                    UserDefaults.standard.set(email, forKey: "email")
                    UserDefaults.standard.set(tel, forKey: "user")
                    //переходим на страницу ввода нового пароля
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "fromSignUpToNewPasswordVC", sender: nil)
                    }
                }
                else if statusCode == 409 {
                    print ("User exists, data = \(data), thread \(Thread.isMainThread)")
                    DispatchQueue.main.async {
                        Alerts.showErrorAlert(VC: self, message: "Пользователь уже существует")
                    }
                                    }
                else if statusCode == 500 {
                    print ("Incorrect phone number, data = \(data), thread \(Thread.isMainThread)")
                    DispatchQueue.main.async {
                        Alerts.showErrorAlert(VC: self, message: "Некорректный номер телефона")
                    }
                }
                else if statusCode == 400 {
                    print ("Incorrect email, data = \(data), thread \(Thread.isMainThread)")
                    DispatchQueue.main.async {
                        Alerts.showErrorAlert(VC: self, message: "Некорректный адрес электронной почты")
                    }
                }
                else {
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
        self.signUpBtn.backgroundColor = UIColor(red:0.37, green:0.75, blue:0.62, alpha:1.0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension SignUpViewController: CheckboxDelegate {
    func checked(_ checkbox: Checkbox) {
        if checkbox.isChecked {
            signUpBtn.isEnabled = true
            signUpBtn.backgroundColor = UIColor(red:0.37, green:0.75, blue:0.62, alpha:1.0)
        }
        else {
            signUpBtn.isEnabled = false
            signUpBtn.backgroundColor = UIColor(red:0.75, green:0.75, blue:0.75, alpha:1.0)
        }
    }
}

