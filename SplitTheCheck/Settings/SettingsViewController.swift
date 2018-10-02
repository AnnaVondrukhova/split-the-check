//
//  SettingsViewController.swift
//  SplitTheCheck
//
//  Created by Anya on 28/09/2018.
//  Copyright © 2018 Anna Zhulidova. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet weak var logOutBtn: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false 
    }
    
    @IBAction func logOut(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        print("Is logged in = \(UserDefaults.standard.bool(forKey: "isLoggedIn"))")
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        present(nextViewController, animated:true, completion:nil)
    }
}
