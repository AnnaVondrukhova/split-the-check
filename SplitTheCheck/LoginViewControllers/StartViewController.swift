//
//  StartViewController.swift
//  SplitTheCheck
//
//  Created by Anya on 14/07/2018.
//  Copyright © 2018 Anna Vondrukhova. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import RealmSwift

class StartViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //запускаем логирование в файл
        let docDirectory: NSString = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as NSString
        let logpath = docDirectory.appendingPathComponent("log.txt")
        
//        freopen(logpath.cString(using: String.Encoding.ascii)!, "w+", stderr)
//        print ("rewriting file")
        do {
            let attributes: NSDictionary = try FileManager.default.attributesOfItem(atPath: logpath) as NSDictionary
            let fileSize = attributes.fileSize()
            if fileSize <= 1000000 {
                freopen(logpath.cString(using: String.Encoding.ascii)!, "a+", stderr)
                print ("adding to file")
            } else {
                freopen(logpath.cString(using: String.Encoding.ascii)!, "w+", stderr)
                print ("rewriting file")
            }
        } catch {
            print (error)
            freopen(logpath.cString(using: String.Encoding.ascii)!, "w+", stderr)
            print ("error: rewriting file")
        }
        
        print("StartView did load")
        NSLog("StartVC did load. Is logged in = \(UserDefaults.standard.bool(forKey: "isLoggedIn"))")
                
        //Тестовый блок - УДАЛИТЬ
//        let domain = Bundle.main.bundleIdentifier!
//        UserDefaults.standard.removePersistentDomain(forName: domain)
//
//        print ("UserDefaults cleared")
//        UserDefaults.standard.set(false, forKey: "isLoggedIn")

    }
    
    //проверка на автоматический вход в приложение
    override func viewDidAppear(_ animated: Bool) {
        //запрос на авторизацию
        if UserDefaults.standard.bool(forKey: "isLoggedIn") {
            print("isLoggedIn")
            self.performSegue(withIdentifier: "toCheckHistoryVC", sender: nil)
        }
        
        else {
            self.performSegue(withIdentifier: "toLoginVC", sender: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
