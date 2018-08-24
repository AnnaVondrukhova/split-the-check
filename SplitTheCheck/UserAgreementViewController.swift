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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

