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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.telText.delegate = self
        telText.keyboardType = UIKeyboardType.numberPad
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print ("did begin editing")
        if telText.text == "" {
            print ("+7")
            telText.text = "+7"
        }
    }
    
    @IBAction func getNewPwd(_ sender: Any) {
        //получаем новый пароль по номеру телефона
        getPwdBtn.backgroundColor = UIColor(red:0.47, green:0.47, blue:0.47, alpha:1.0)
        getPwdBtn.titleLabel?.textColor = UIColor(red:0.75, green:0.75, blue:0.75, alpha:1.0)
        
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
                self.showAlert(message: "Ошибка соединения с сервером")
                return
            }
            
            let httpResponse = response as? HTTPURLResponse
            
            //если ответ получен, то:
            if httpResponse != nil {
                let statusCode = httpResponse!.statusCode
                print("Status code = \(statusCode)")
                
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
                    self.showAlert(message: "Пользователь не найден")
                }
                else {
                    print ("Unknown error, status code = \(statusCode), data = \(data)")
                    self.showAlert(message: "Ошибка соединения с сервером")
                }
            }
            else {
                print (httpResponse!.allHeaderFields)
                self.showAlert(message: "Ошибка соединения с сервером")
            }
        }
        
        task.resume()

    }
    
    func  showAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
