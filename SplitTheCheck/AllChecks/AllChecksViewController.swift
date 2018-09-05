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

    var storedChecks: Results<QrStringInfoObject>?
    var jsonString = ""
    let requestResult = RequestService()
    var token: NotificationToken?
    var modifiedString = QrStringInfoObject()
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var waitingLabel: UILabel = UILabel()
    var waitingView: UIView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //задаем параметры ActivityIndicatorView и сопутствующих элементов
        waitingView.backgroundColor = UIColor.lightGray
        waitingView.layer.cornerRadius = 10
        waitingView.frame.size = CGSize(width: 180, height: 20 + activityIndicator.frame.height + 48)
        waitingView.center = self.view.center
        waitingView.layer.opacity = 0.8
        self.view.addSubview(waitingView)
        self.view.bringSubview(toFront: waitingView)
        
        activityIndicator.color = UIColor.white
        activityIndicator.center.x = waitingView.center.x
        activityIndicator.center.y = waitingView.frame.minY + 20 + activityIndicator.frame.height/2
        self.view.addSubview(activityIndicator)
        self.view.bringSubview(toFront: activityIndicator)
        activityIndicator.isHidden = false
        activityIndicator.hidesWhenStopped = true
        
        waitingLabel.text = "Обработка чека..."
        waitingLabel.textAlignment = .center
        waitingLabel.textColor = UIColor.white
        waitingLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        waitingLabel.frame.size = CGSize(width: 140, height: 20)
        waitingLabel.center.x = waitingView.center.x
        waitingLabel.center.y = activityIndicator.frame.maxY + 18
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
        waitingLabel.isHidden = true
        waitingView.isHidden = true
        
        do {
            let realm = try Realm()
            self.storedChecks = realm.objects(QrStringInfoObject.self)
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
            modifiedString = storedChecks!.reversed()[indexPath.item]
            performSegue(withIdentifier: "showCheckSegue", sender: nil)
        }
        //если информация о чеке еще не загружена, пробуем загрузить
        else if (collectionView.cellForItem(at: indexPath) as? NotLoadedCheckCell) != nil {
            print("cell as NotLoadedCheckCell")
            waitingLabel.isHidden = false
            waitingView.isHidden = false
            activityIndicator.startAnimating()
            RequestService.loadData(receivedString: storedChecks!.reversed()[indexPath.item].qrString)
            RealmServices.getStringFromRealm(VC: self, qrString: storedChecks!.reversed()[indexPath.item].qrString)
        }
    }


    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Если отсканированных чеков еще нет, показываем на экране надпись
        if (storedChecks != nil) && (storedChecks?.isEmpty == false) {
            print ("stored checks not nil or empty")
            self.collectionView?.backgroundView = nil
            return storedChecks!.count
        } else {
            let bounds = CGRect(x: 0, y: 0, width: (self.collectionView?.bounds.size.width)!, height: (self.collectionView?.bounds.size.height)!)
            let noDataLabel = UILabel(frame: bounds)
            noDataLabel.text = "Нет отсканированных чеков"
            noDataLabel.textAlignment = .center
            noDataLabel.textColor = UIColor.lightGray
            noDataLabel.font = UIFont.systemFont(ofSize: 15)
            noDataLabel.sizeToFit()
            self.collectionView?.backgroundView = noDataLabel
            
            return 0
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if storedChecks!.reversed()[indexPath.item].jsonString != nil && storedChecks!.reversed()[indexPath.item].jsonString != "null"  {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "loadedCheck", for: indexPath) as? LoadedCheckCell {
                
                cell.configure(jsonString: storedChecks!.reversed()[indexPath.item].jsonString!)
                return cell
            }
        } else {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "notLoadedCheck", for: indexPath) as? NotLoadedCheckCell {
                
                cell.configure(qrString: storedChecks!.reversed()[indexPath.item].qrString)
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

