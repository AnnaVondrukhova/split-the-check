//
//  LoginViewController.swift
//  SplitTheCheck
//
//  Created by Anya on 16/07/2018.
//  Copyright © 2018 Anna Vondrukhova. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class LoginViewController: UIViewController, UITextFieldDelegate, UIViewControllerTransitioningDelegate {
    @IBOutlet weak var loginText: UITextField!
    @IBOutlet weak var pwdText: UITextField!
    @IBOutlet weak var forgetBtn: UIButton!
    @IBOutlet weak var signUpBtn: CustomButton!
    @IBOutlet weak var checkbox: Checkbox!
    @IBOutlet weak var iAcceptLabel: UILabel!
    @IBOutlet weak var logInBtn: CustomButton!
    @IBOutlet weak var waitingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var agreementBtn: UIButton = UIButton()
    let url = "https://lkfl2.nalog.ru/lkfl/login"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print ("LoginVC did load")
        NSLog ("LoginVC did load")
        
        waitingView.layer.cornerRadius = 10
        waitingView.layer.opacity = 1
        self.activityIndicator.hidesWhenStopped = true
        self.loginText.delegate = self
        loginText.keyboardType = UIKeyboardType.numberPad
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        logInBtn.isEnabled = false
        logInBtn.backgroundColor = UIColor(red:0.75, green:0.75, blue:0.75, alpha:1.0)
        checkbox.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        waitingView.isHidden = true
        
        NSLog ("LoginVC will appear")
    }
    
    override func viewWillLayoutSubviews() {
        setUpAgreementBtn()
    }
    
    func setUpAgreementBtn() {
        agreementBtn.setTitleColor(UIColor(red:0.37, green:0.75, blue:0.62, alpha:1.0), for: .normal)
        agreementBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        agreementBtn.setTitle("пользовательского соглашения", for: .normal)
        
        if self.view.frame.width < 370 {
            agreementBtn.frame = CGRect(x: 42, y: iAcceptLabel.frame.minY + 15, width: 193, height: 15)
            print ("\(agreementBtn.frame.minX), \(agreementBtn.frame.minY)")
        } else {
            agreementBtn.frame.size = CGSize(width: 193, height: 15)
            agreementBtn.center.y = iAcceptLabel.center.y
            agreementBtn.frame.origin.x = iAcceptLabel.frame.maxX
        }
        self.view.addSubview(agreementBtn)
        self.view.bringSubview(toFront: agreementBtn)
        agreementBtn.addTarget(self, action: #selector(agreementBtnTap(_:)), for: .touchUpInside)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
    
    //вызываем экран с пользовательским соглашением
    @objc func agreementBtnTap(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let userAgreementVC = storyboard.instantiateViewController(withIdentifier: "UserAgreementVC") as! UserAgreementViewController
        userAgreementVC.modalPresentationStyle = UIModalPresentationStyle.custom
        userAgreementVC.transitioningDelegate = self
        self.present(userAgreementVC, animated: true, completion: nil)
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return partialVC(presentedViewController: presented, presenting: presenting)
    }
    
    @IBAction func forgetBtnPressed(_ sender: Any) {
        UIApplication.shared.open(URL(string: url)!, options: [:], completionHandler: nil)
    }
    
    @IBAction func signUpBtnPressed(_ sender: Any) {
        UIApplication.shared.open(URL(string: url)!, options: [:], completionHandler: nil)
    }
    
    
    @IBAction func logIn(_ sender: Any) {
        logInBtn.backgroundColor = UIColor(red:0.75, green:0.75, blue:0.75, alpha:1.0)
        waitingView.isHidden = false
        activityIndicator.startAnimating()
        
        loginText.endEditing(true)
        pwdText.endEditing(true)
        
        //при нажатии кнопки "Войти" пробуем авторизоваться
        NSLog("Trying to authorize...")
        let user = loginText.text ?? ""
        let password = pwdText.text ?? ""
        
        UserDefaults.standard.set(user, forKey: "user")
        UserDefaults.standard.set(password, forKey: "password")
        
        NetworkService.shared.getSessionId { (sessionId, error, statusCode) in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.waitingView.isHidden = true
            }
            
            if statusCode == 200 {
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "fromLoginToCheckHistoryVC", sender: nil)
                }
            }
            else if statusCode == 403 {
                //если авторизация не прошла, выдаем ошибку
                DispatchQueue.main.async {
                    Alerts.showErrorAlert(VC: self, message: "Неверный ИНН или пароль")
                }
            } else {
                //при неизвестной ошибке проверяем соединение с интернетом или выдаем ошибку соединения с сервером
                guard let underlyingError = error?.asAFError?.underlyingError  else {
                    print ("Unknown error: \(error.debugDescription), status code = \(statusCode)" )
                    NSLog ("Unknown error: \(error.debugDescription), status code = \(statusCode)")
                    DispatchQueue.main.async {
                        Alerts.showErrorAlert(VC: self, message: "Ошибка соединения с сервером")
                    }
                    return
                }
                
                if let urlError = underlyingError as? URLError {
                    switch urlError.code {
                    case .timedOut:
                        print ("Timeout error: \(error.debugDescription), status code = \(statusCode)" )
                        NSLog ("Timeout error: \(error.debugDescription), status code = \(statusCode)")
                        DispatchQueue.main.async {
                            Alerts.showErrorAlert(VC: self, message: "Превышено время ожидания ответа от сервера")
                        }
                    case .notConnectedToInternet:
                        print ("No internet error: \(error.debugDescription), status code = \(statusCode)" )
                        NSLog ("No internet error: \(error.debugDescription), status code = \(statusCode)")
                        DispatchQueue.main.async {
                            Alerts.showErrorAlert(VC: self, message: "Нет соединения с интернетом")
                        }
                    default:
                        print ("Unknown error: \(error.debugDescription), status code = \(statusCode)" )
                        NSLog ("Unknown error: \(error.debugDescription), status code = \(statusCode)")
                        DispatchQueue.main.async {
                            Alerts.showErrorAlert(VC: self, message: "Ошибка соединения с сервером")
                        }
                    }
                }
            }
            
            
            DispatchQueue.main.async {
                self.checkbox.isChecked = false
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension LoginViewController: CheckboxDelegate {
    //кнопка регистрации недоступна, если чекбокс не отмечен
    func checked(_ checkbox: Checkbox) {
        if checkbox.isChecked {
            logInBtn.isEnabled = true
            logInBtn.backgroundColor = UIColor(red:0.37, green:0.75, blue:0.62, alpha:1.0)
        }
        else {
            logInBtn.isEnabled = false
            logInBtn.backgroundColor = UIColor(red:0.75, green:0.75, blue:0.75, alpha:1.0)
        }
    }
}
