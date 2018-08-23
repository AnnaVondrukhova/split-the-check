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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toUserAgreementVC" {
            print("Go to UserAgreementViewController")
            let controller = segue.destination as! UserAgreementViewController
            controller.name = nameText.text ?? ""
            controller.email = emailText.text ?? ""
            controller.tel = telText.text ?? ""
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
