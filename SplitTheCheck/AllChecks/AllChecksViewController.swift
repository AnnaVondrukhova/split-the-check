//
//  CheckHistoryViewController.swift
//  SplitTheCheck
//
//  Created by Anya on 22/01/2018.
//  Copyright © 2018 Anna Zhulidova. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift


class AllChecksViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var storedChecks: [QrStringInfoObject]?
    var jsonString = ""
    let requestResult = RequestService()
    var token: NotificationToken?
    var modifiedString = QrStringInfoObject()
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var waitingLabel: UILabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.color = UIColor.darkGray
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        self.view.bringSubview(toFront: activityIndicator)
        
        waitingLabel.text = "Обработка чека..."
        waitingLabel.textColor = UIColor.darkGray
        waitingLabel.font = UIFont.systemFont(ofSize: 15)
        waitingLabel.frame.size = CGSize(width: 127, height: 20)
        waitingLabel.center.x = self.view.center.x
        waitingLabel.center.y = self.view.center.y + activityIndicator.frame.height/2 + 18
        self.view.addSubview(waitingLabel)
        self.view.bringSubview(toFront: waitingLabel)
        
//        do {
//            let realm = try Realm()
//
//            //!!!УДАЛИТЬ: очищаем Realm каждый раз перед запуском
//            realm.beginWrite()
//            realm.deleteAll()
//            try! realm.commitWrite()
//        } catch {
//            print(error.localizedDescription)
//        }
//        UserDefaults.standard.set(false, forKey: "notFirstLaunch")
//

//                    Realm.Configuration.defaultConfiguration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
//                    print("configuration changed")
        
        //если это первый запуск программы, записываем имя пользователя как первого гостя
        if !UserDefaults.standard.bool(forKey: "notFirstLaunch") {
            let userName = UserDefaults.standard.string(forKey: "name") ?? "Я"
            do {
                let realm = try Realm()
                realm.beginWrite()
                realm.add(User())
                let user = realm.objects(User.self).first
                user?.guests.append(GuestInfoObject(name: userName))
                try realm.commitWrite()
            } catch {
                print(error.localizedDescription)
            }
            
            UserDefaults.standard.set(true, forKey: "notFirstLaunch")
        }
        
    }

    //при переходе на экран получаем из базы список чеков с основной информацией
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        activityIndicator.isHidden = true
        waitingLabel.isHidden = true
        
        do {
            let realm = try Realm()
            self.storedChecks = realm.objects(QrStringInfoObject.self).reversed()
            print(realm.configuration.fileURL as Any)
        } catch {
            print(error.localizedDescription)
        }

        self.collectionView?.reloadData()
        print("data reloaded")
    }
    
    //задаем ширину ячеек
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.bounds.width - 20, height: 60)
    }
    
    //если мы выбираем в списке чек, то...
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //если информация о чеке загружена, переходим на страницу с информацией
        if (collectionView.cellForItem(at: indexPath) as? LoadedCheckCell) != nil {
            modifiedString = storedChecks![indexPath.item]
            performSegue(withIdentifier: "showCheckSegue", sender: nil)
        }
        //если информация о чеке еще не загружена, пробуем загрузить
        else if (collectionView.cellForItem(at: indexPath) as? NotLoadedCheckCell) != nil {
            print("cell as NotLoadedCheckCell")
            activityIndicator.isHidden = false
            waitingLabel.isHidden = false
            activityIndicator.startAnimating()
            RequestService.loadData(receivedString: storedChecks![indexPath.item].qrString)
            RealmServices.getStringFromRealm(VC: self, qrString: storedChecks![indexPath.item].qrString)
        }
    }


    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if storedChecks != nil {
            return storedChecks!.count
        } else {
            return 0
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if storedChecks![indexPath.item].jsonString != nil && storedChecks![indexPath.item].jsonString != "null"  {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "loadedCheck", for: indexPath) as? LoadedCheckCell {
                
                cell.configure(jsonString: storedChecks![indexPath.item].jsonString!)
                return cell
            }
        } else {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "notLoadedCheck", for: indexPath) as? NotLoadedCheckCell {
                
                cell.configure(qrString: storedChecks![indexPath.item].qrString)
                return cell
            }
        }
        return UICollectionViewCell()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //если переходим с ячейки с уже загруженным чеком
        if segue.identifier == "showCheckSegue" {
            print ("trying to load check")
            let controller = segue.destination as! CheckInfoViewController
            
            controller.parentString = modifiedString
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print ("checkHistoryView disappears")
        token = nil
    }
    deinit {
        token?.invalidate()
    }

}
