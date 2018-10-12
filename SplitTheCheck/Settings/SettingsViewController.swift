//
//  SettingsViewController.swift
//  SplitTheCheck
//
//  Created by Anya on 28/09/2018.
//  Copyright © 2018 Anna Zhulidova. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var logOutBtn: UILabel!
    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var sortPicker: UIPickerView!
    @IBOutlet weak var saveSwitch: UISwitch!
    
    var sortPickerData = [String]()
    let sortType = UserDefaults.standard.integer(forKey: "sortType")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sortPicker.delegate = self
        self.sortPicker.dataSource = self
        
        sortPickerData = ["По дате добавления", "По дате чека"]
        sortPicker.isHidden = true
        
        saveSwitch.isOn = true

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        
        self.self.sortButton.setTitle(self.sortPickerData[sortType], for: .normal)
    }
    
    //настраиваем log out
    @IBAction func logOut(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        print("Is logged in = \(UserDefaults.standard.bool(forKey: "isLoggedIn"))")
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        present(nextViewController, animated:true, completion:nil)
    }
    
    //настраиваем picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sortPickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sortPickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.sortButton.setTitle(self.sortPickerData[row], for: .normal)
        UserDefaults.standard.set(row, forKey: "sortType")
    }

    //обрабатываем нажатие кнопки сиртировки
    @IBAction func sortBtnTap(_ sender: Any) {
        sortPicker.isHidden = !sortPicker.isHidden
    }
    
    //обрабатываем изменение saveSwitch
    @IBAction func saveSwitchTap(_ sender: Any) {
        saveSwitch.setOn(!saveSwitch.isOn, animated: true)
        saveSwitch.isOn = !saveSwitch.isOn
        UserDefaults.standard.set(saveSwitch.isOn, forKey: "autoSave")
        print ("save is on = \(saveSwitch.isOn)")
    }
    
}
