//
//  SignUpViewController.swift
//  SplitTheCheck
//
//  Created by Anya on 17/07/2018.
//  Copyright © 2018 Anna Zhulidova. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate, UIViewControllerTransitioningDelegate {

    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var telText: UITextField!
    @IBOutlet weak var checkbox: Checkbox!
    @IBOutlet weak var agreementBtn: UIButton!
    @IBOutlet weak var signUpBtn: CustomButton!
    @IBOutlet weak var waitingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSLog ("SignUpVC did load")

        waitingView.layer.cornerRadius = 10
        waitingView.layer.opacity = 0.8
        self.activityIndicator.hidesWhenStopped = true
        self.telText.delegate = self
        telText.keyboardType = UIKeyboardType.numberPad
//        agreementBtn.titleLabel?.attributedText = NSAttributedString(string: (agreementBtn.titleLabel?.text!)!, attributes: [.underlineStyle: NSUnderlineStyle.styleSingle.rawValue])
        signUpBtn.isEnabled = false
        signUpBtn.backgroundColor = UIColor(red:0.75, green:0.75, blue:0.75, alpha:1.0)
        checkbox.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        waitingView.isHidden = true
        NSLog ("SignUpVC will appear")
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        print ("did begin editing")
        if telText.text == "" {
            print ("+7")
            telText.text = "+7"
        }
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
    
    @IBAction func signUp(_ sender: Any) {
        //регистрируем пользователя
        signUpBtn.backgroundColor = UIColor(red:0.75, green:0.75, blue:0.75, alpha:1.0)
        waitingView.isHidden = false
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
        self.signUpBtn.backgroundColor = UIColor(red:0.37, green:0.75, blue:0.62, alpha:1.0)
    }
    
    //вызываем экран с пользовательским соглашением
    @IBAction func agreementBtnTap(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let userAgreementVC = storyboard.instantiateViewController(withIdentifier: "UserAgreementVC") as! UserAgreementViewController
        userAgreementVC.modalPresentationStyle = UIModalPresentationStyle.custom
        userAgreementVC.transitioningDelegate = self
        self.present(userAgreementVC, animated: true, completion: nil)
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return partialVC(presentedViewController: presented, presenting: presenting)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension SignUpViewController: CheckboxDelegate {
    //кнопка регистрации недоступна, если чекбокс не отмечен
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

