//
//  UserAgreementViewController.swift
//  SplitTheCheck
//
//  Created by Anya on 21/08/2018.
//  Copyright © 2018 Anna Zhulidova. All rights reserved.
//

import UIKit

class UserAgreementViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var agreementLabel: UILabel!
    @IBOutlet var cancelBtn: UIView!
    @IBOutlet weak var nextBtn: CustomButton!
    @IBOutlet weak var checkbox: Checkbox!
    
    var name = ""
    var email = ""
    var tel = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        checkbox.delegate = self
        nextBtn.isEnabled = false
        nextBtn.backgroundColor = UIColor.gray
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextAction(_ sender: Any) {
        //регистрируем пользователя
        nextBtn.backgroundColor = UIColor(red:0.47, green:0.47, blue:0.47, alpha:1.0)
        nextBtn.titleLabel?.textColor = UIColor(red:0.75, green:0.75, blue:0.75, alpha:1.0)
        
        let url = URL(string: "https://proverkacheka.nalog.ru:9999/v1/mobile/users/signup")
        
        var request = URLRequest(url: url!)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let headers = ["email":email,"name":name,"phone":tel]
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
                    //запоминаем имя, email и телефон-логин
                    UserDefaults.standard.set(self.name, forKey: "name")
                    UserDefaults.standard.set(self.email, forKey: "email")
                    UserDefaults.standard.set(self.tel, forKey: "user")
                    //переходим на страницу ввода нового пароля
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "fromArgeementToNewPasswordVC", sender: nil)
                    }
                }
                else if statusCode == 409 {
                    print ("User exists, data = \(data)")
                    self.showAlert(message: "Пользователь уже существует")
                }
                else if statusCode == 500 {
                    print ("Incorrect phone number, data = \(data)")
                    self.showAlert(message: "Некорректный номер телефона")
                }
                else if statusCode == 400 {
                    print ("Incorrect email, data = \(data)")
                    self.showAlert(message: "Некорректный адрес электронной почты")
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
        
        let action = UIAlertAction(title: "OK", style: .cancel, handler: {(action: UIAlertAction) in self.dismiss(animated: true, completion: nil)})
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

extension UserAgreementViewController: CheckboxDelegate {
    func checked(_ button: Checkbox) {
        if button.isChecked {
            nextBtn.isEnabled = true
            nextBtn.backgroundColor = UIColor(red:0.49, green:0.25, blue:0.84, alpha:1.0)
        }
        else {
            nextBtn.isEnabled = false
            nextBtn.backgroundColor = UIColor.gray
        }
    }
    
    
}
