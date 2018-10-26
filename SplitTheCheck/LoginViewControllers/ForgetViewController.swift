//
//  ForgetViewController.swift
//  SplitTheCheck
//
//  Created by Anya on 18/07/2018.
//  Copyright © 2018 Anna Zhulidova. All rights reserved.
//

import UIKit

class ForgetViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var telText: UITextField!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var getPwdBtn: CustomButton!
    @IBOutlet weak var waitingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSLog ("ForgetVC did load")
        waitingView.layer.cornerRadius = 10
        waitingView.layer.opacity = 0.8
        self.activityIndicator.hidesWhenStopped = true
        self.telText.delegate = self
        telText.keyboardType = UIKeyboardType.numberPad
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        waitingView.isHidden = true
        NSLog ("ForgetVC will appear")
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
    
    @IBAction func getNewPwd(_ sender: Any) {
        //получаем новый пароль по номеру телефона
        getPwdBtn.backgroundColor = UIColor(red:0.75, green:0.75, blue:0.75, alpha:1.0)
        waitingView.isHidden = false
        activityIndicator.startAnimating()
        
        let url = URL(string: "https://proverkacheka.nalog.ru:9999/v1/mobile/users/restore")
        
        var request = URLRequest(url: url!)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let telNumber = telText.text ?? ""
        let headers = ["phone": telNumber]
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
                    //запоминаем телефон-логин
                    UserDefaults.standard.set(telNumber, forKey: "user")
                    //переходим на страницу ввода нового пароля
                    DispatchQueue.main.async {
                         self.performSegue(withIdentifier: "toNewPasswordVC", sender: nil)
                    }
                }
                else if statusCode == 404 {
                    print ("User was not found, data = \(data)")
                    DispatchQueue.main.async {
                        Alerts.showErrorAlert(VC: self, message: "Пользователь не найден")
                    }
                }
                else {
                    print ("Unknown error, status code = \(statusCode), data = \(data)")
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
        self.getPwdBtn.backgroundColor = UIColor(red:0.37, green:0.75, blue:0.62, alpha:1.0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
