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


class AllChecksViewController: UITableViewController {

    var storedChecks: List<QrStringInfoObject>?
    var groupedChecks: [YearMonth: [QrStringInfoObject]]?
    var jsonString = ""
    let requestResult = RequestService()
    var token: NotificationToken?
    var modifiedString = QrStringInfoObject()
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var waitingLabel: UILabel = UILabel()
    var waitingView: UIView = UIView()
    var sortedKeys =  [YearMonth]()
    var noChecksLabel: UILabel = UILabel()
    let userId = UserDefaults.standard.string(forKey: "user")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //задаем параметры надписи на заднем плане по умолчанию
        let bounds = CGRect(x: 0, y: 0, width: (self.tableView?.bounds.size.width)!, height: (self.tableView?.bounds.size.height)!)
        noChecksLabel.bounds = bounds
        noChecksLabel.text = "Нет отсканированных чеков"
        noChecksLabel.textAlignment = .center
        noChecksLabel.textColor = UIColor.lightGray
        noChecksLabel.font = UIFont.systemFont(ofSize: 15)
        noChecksLabel.sizeToFit()
        self.tableView?.backgroundView = noChecksLabel

        //убираем разделитель
        self.tableView.separatorColor = UIColor.clear
        
        //задаем параметры ActivityIndicatorView и сопутствующих элементов
        waitingView.backgroundColor = UIColor.lightGray
        waitingView.layer.cornerRadius = 10
        waitingView.frame.size = CGSize(width: 180, height: 20 + activityIndicator.frame.height + 48)
        waitingView.center = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
        print (waitingView.center)
        waitingView.layer.opacity = 0.8
        self.navigationController?.view.addSubview(waitingView)
        self.navigationController?.view.bringSubview(toFront: waitingView)
        
        activityIndicator.color = UIColor.white
        activityIndicator.center.x = waitingView.center.x
        activityIndicator.center.y = waitingView.frame.minY + 20 + activityIndicator.frame.height/2
        self.navigationController?.view.addSubview(activityIndicator)
        self.navigationController?.view.bringSubview(toFront: activityIndicator)
        activityIndicator.isHidden = false
        activityIndicator.hidesWhenStopped = true
        
        waitingLabel.text = "Обработка чека..."
        waitingLabel.textAlignment = .center
        waitingLabel.textColor = UIColor.white
        waitingLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        waitingLabel.frame.size = CGSize(width: 140, height: 20)
        waitingLabel.center.x = waitingView.center.x
        waitingLabel.center.y = activityIndicator.frame.maxY + 18
        self.navigationController?.view.addSubview(waitingLabel)
        self.navigationController?.view.bringSubview(toFront: waitingLabel)
        
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
//        UserDefaults.standard.set(false, forKey: "notFirstLaunchFor\(userId!)")
//
//                    Realm.Configuration.defaultConfiguration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
//                    print("configuration changed")
        
        //если это первый запуск программы, записываем имя пользователя как первого гостя
        
        if !UserDefaults.standard.bool(forKey: "notFirstLaunchFor\(userId!)") {
            let userName = UserDefaults.standard.string(forKey: "name") ?? "Я"
            do {
                let realm = try Realm()
                realm.beginWrite()
                realm.add(User(id: userId!))
                let user = realm.object(ofType: User.self, forPrimaryKey: userId)
                user?.guests.append(GuestInfoObject(name: userName))
                try realm.commitWrite()
            } catch {
                print(error.localizedDescription)
            }
            
            UserDefaults.standard.set(true, forKey: "notFirstLaunchFor\(userId!)")
        }
        
    }

    //при переходе на экран получаем из базы список чеков с основной информацией
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        waitingLabel.isHidden = true
        waitingView.isHidden = true
        
        do {
            let realm = try Realm()
            let user = realm.object(ofType: User.self, forPrimaryKey: self.userId)
            if user?.checks != nil {
                self.storedChecks = user?.checks
            }
            print(realm.configuration.fileURL as Any)
        } catch {
            print(error.localizedDescription)
        }
        
        self.groupedChecks = [YearMonth: [QrStringInfoObject]]()
        
        //группируем чеки
        guard self.storedChecks != nil else { return }
        var yearMonthChecks = [QrStringInfoObject]()
            //сортируем чеки по убыванию даты, чтобы в пределах группы они располагались по убыванию
        let storedChecksSorted = storedChecks?.sorted(byKeyPath: "checkDate", ascending: false)
        for check in storedChecksSorted! {
            let yearMonth = YearMonth(date: check.checkDate!)
            yearMonthChecks = groupedChecks![yearMonth, default: [QrStringInfoObject]()]
            yearMonthChecks.append(check)
            self.groupedChecks![yearMonth] = yearMonthChecks
        }
        
            //сортируем ключи бо убыванию
        self.sortedKeys = groupedChecks!.keys.sorted(by: >)

        self.tableView?.reloadData()
        print("data reloaded")
    }
    
    //если мы выбираем в списке чек, то...
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //если информация о чеке загружена, переходим на страницу с информацией
        if (tableView.cellForRow(at: indexPath) as? LoadedCheckCell) != nil {
            modifiedString = groupedChecks![sortedKeys[indexPath.section]]![indexPath.row]
            performSegue(withIdentifier: "showCheckSegue", sender: self)
        }
        //если информация о чеке еще не загружена, пробуем загрузить
        else if (tableView.cellForRow(at: indexPath) as? NotLoadedCheckCell) != nil {
            print("cell as NotLoadedCheckCell")
            waitingLabel.isHidden = false
            waitingView.isHidden = false
            activityIndicator.startAnimating()
            RequestService.loadData(receivedString: groupedChecks![sortedKeys[indexPath.section]]![indexPath.row].qrString)
            RealmServices.getStringFromRealm(VC: self, qrString: groupedChecks![sortedKeys[indexPath.section]]![indexPath.row].qrString)
        }
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        if sortedKeys.count == 0 {
            self.tableView?.backgroundView = noChecksLabel
        } else {
            self.tableView?.backgroundView = nil
        }
        return sortedKeys.count
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Если отсканированных чеков еще нет, показываем на экране надпись
        if (storedChecks != nil) && (storedChecks?.isEmpty == false) {
            print ("stored checks not nil or empty")
//            self.noChecksLabel.isHidden = true
//            self.tableView?.backgroundView = nil
            return groupedChecks![sortedKeys[section]]!.count
        } else {
//            self.tableView?.backgroundView = noChecksLabel
//            self.noChecksLabel.isHidden = false
            return 0
        }
    }
    
    //задаем конфигурацию header view
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let sectionHeader = tableView.dequeueReusableCell(withIdentifier: "dateHeader") as? AllChecksHeaderCell {
            sectionHeader.configure(date: sortedKeys[section])
            return sectionHeader
        }
        
        return UICollectionReusableView()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    //задаем конфигурацию ячейки
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if groupedChecks![sortedKeys[indexPath.section]]![indexPath.row].jsonString != nil && groupedChecks![sortedKeys[indexPath.section]]![indexPath.row].jsonString != "null"  {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "loadedCheck", for: indexPath) as? LoadedCheckCell {
                
                cell.configure(jsonString: groupedChecks![sortedKeys[indexPath.section]]![indexPath.row].jsonString!)
                return cell
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "notLoadedCheck", for: indexPath) as? NotLoadedCheckCell {
                
                cell.configure(qrString: groupedChecks![sortedKeys[indexPath.section]]![indexPath.row].qrString)
                return cell
            }
        }
        return UITableViewCell()
    }
    
    //если удаляем строку, то удаляем чек из базы
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            do {
                let realm = try Realm()
                realm.beginWrite()
                let qrString = groupedChecks![sortedKeys[indexPath.section]]![indexPath.row].qrString
                groupedChecks![sortedKeys[indexPath.section]]!.remove(at: indexPath.row)
                if groupedChecks![sortedKeys[indexPath.section]]!.isEmpty {
                    sortedKeys.remove(at: indexPath.section)
                }
                let realmQrString = realm.object(ofType: QrStringInfoObject.self, forPrimaryKey: qrString)!
                let realmItems = realm.objects(CheckInfoObject.self).filter("%@ IN parent", realmQrString)
                realm.delete(realmItems)
                realm.delete(realmQrString)
                try realm.commitWrite()
                print ("deleted row \(qrString)")
                tableView.reloadData()
            } catch {
                print (error.localizedDescription)
            }
        }
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

