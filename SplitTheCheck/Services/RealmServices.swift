//
//  RealmServices.swift
//  SplitTheCheck
//
//  Created by Anya on 29/08/2018.
//  Copyright © 2018 Anna Zhulidova. All rights reserved.
//

import Foundation
import RealmSwift

class RealmServices {
    
    //сохраняем наш объект QrStringInfo в базу данных
    static func saveQRString(string: QrStringInfoObject) {
        let userId = UserDefaults.standard.string(forKey: "user")
        do {
            let realm = try Realm()
            realm.beginWrite()
            let user = realm.object(ofType: User.self, forPrimaryKey: userId)
            if (user?.checks.filter("qrString = %@", string.qrString).isEmpty)! {
                user?.checks.append(string)
                print ("added string to Realm")
                NSLog ("saveQRString: added string to Realm")
            } else {
                realm.add(string, update: true)
                print ("updated string in Realm")
                NSLog ("saveQRString: updated string in Realm")
            }
            try realm.commitWrite()
            print(realm.configuration.fileURL as Any)
        } catch {
            print(error)
            NSLog ("saveQRString: error " + error.localizedDescription)
        }
    }
    
    //Нотификация о добавлении данных в базe для ScanViewController.
    //если была добавлена строка, записываем ее в addedString. Если в ней есть ошибка, выдаем алерт с ошибкой.
    //если ошибки нет, передаем полученную строку на CheckInfoViewController и переходим туда
    static func getStringFromRealm(VC: ScanViewController) {
        print ("getStringFromRealm for ScanViewController")
        NSLog ("starting getStringFromRealm for ScanViewController")
        
        guard let realm = try? Realm() else {return}
        VC.storedChecks = realm.objects(QrStringInfoObject.self)
        VC.token = VC.storedChecks?.observe {(changes: RealmCollectionChange) in
            switch changes {
            case .initial ( _):
                print ("initial results downloaded")
            case .update(_, _, let insertions, let modifications):
                print("insertions: \(insertions)")
                print("modifications: \(modifications)")
                NSLog ("insertions: \(insertions), modifications: \(modifications)")
                print ("thread in getStringFromRealm: \(Thread.isMainThread)")
                if insertions != [] {
                    VC.addedString = VC.storedChecks?[insertions[0]]
                }
                else if modifications != [] {
                     VC.addedString = VC.storedChecks?[modifications[0]]
                }
                else {
                    print ("no insertions or modifications")
                }
                
                if VC.addedString?.error != nil {
                    NSLog ("addedString.error = \(VC.addedString?.error ?? "default")")
                    switch  VC.addedString?.error {
                    case "403":
                        VC.activityIndicator.stopAnimating()
                        VC.waitingLabel.isHidden = true
                        VC.waitingView.isHidden = true
                        Alerts.authErrorAlert(VC: VC, message: "Неверный пользователь или пароль. Требуется повторная авторизация")
                    case "406":
                        VC.activityIndicator.stopAnimating()
                        VC.waitingLabel.isHidden = true
                        VC.waitingView.isHidden = true
                        Alerts.showErrorAlert(VC: VC, message: "Чек не найден")
                    case "202":
                        print ("Ошибка 202, повторяем запрос...")
                        usleep(500000)
                        RequestService.loadData(receivedString: VC.qrString)
                    case "500":
                        VC.activityIndicator.stopAnimating()
                        VC.waitingLabel.isHidden = true
                        VC.waitingView.isHidden = true
                        Alerts.showErrorAlert(VC: VC, message: "Отсутствует соединение с сервером")
                    default:
                        VC.activityIndicator.stopAnimating()
                        VC.waitingLabel.isHidden = true
                        VC.waitingView.isHidden = true
                        Alerts.showErrorAlert(VC: VC, message: "Отсутствует соединение с сервером")
                    }
                    //!!ВОПРОС!! Переходить ли на страницу со списком чеков?
                } else {
                    VC.activityIndicator.stopAnimating()
                    VC.waitingLabel.isHidden = true
                    VC.waitingView.isHidden = true
                    NSLog ("addedString.error == nil, performing qrResult segue")
                    VC.performSegue(withIdentifier: "qrResult", sender: nil)
                    print("qrResult segue performed from GetStringFromRealm")
                }
            case .error(let error):
                print(error)
                NSLog ("case error: " + error.localizedDescription)
            }
        }
    }
    
    
    //Нотификация об обновлении данных в базе для AllChecksViewController
    //Если строка была обновлена, записываем ее в modifiedString. Если в ней есть ошибка, выдаем алерт с ошибкой.
    //если ошибки нет, передаем полученную строку на CheckInfoViewController и переходим туда
    static func getStringFromRealm(VC: AllChecksViewController, qrString: String) {
        print ("starting getStringFromRealm for AllChecksViewController")
        guard let realm = try? Realm() else {return}
        let user = realm.object(ofType: User.self, forPrimaryKey: UserDefaults.standard.string(forKey: "user"))
        VC.storedChecks = user?.checks
        VC.token = VC.storedChecks?.observe {(changes: RealmCollectionChange) in
            switch changes {
            case .initial ( _):
                print ("initial results downloaded")
            case .update(_, _, let insertions, let modifications):
                print("insertions: \(insertions)")
                print("modifications: \(modifications)")
                NSLog ("insertions: \(insertions), modifications: \(modifications)")
                if insertions != [] {
                    VC.modifiedString = (VC.storedChecks?[insertions[0]])!
                } else if modifications != [] {
                    VC.modifiedString = (VC.storedChecks?[modifications[0]])!
                } else {
                    print ("no insertions or modifications")
                }

                if VC.modifiedString.error != nil {
                    NSLog ("modifiedString.error = \(VC.modifiedString.error ?? "default")")
                    switch  VC.modifiedString.error {
                    case "403":
                        VC.activityIndicator.stopAnimating()
                        VC.waitingLabel.isHidden = true
                        VC.waitingView.isHidden = true
                        Alerts.authErrorAlert(VC: VC, message: "Неверный пользователь или пароль. Требуется повторная авторизация")
                    case "406":
                        VC.activityIndicator.stopAnimating()
                        VC.waitingLabel.isHidden = true
                        VC.waitingView.isHidden = true
                        Alerts.showErrorAlert(VC: VC, message: "Чек не найден")
                    case "202":
                        print ("Ошибка 202, повторяем запрос...")
                        usleep(500000)
                        RequestService.loadData(receivedString: qrString)
                    case "500":
                        VC.activityIndicator.stopAnimating()
                        VC.waitingLabel.isHidden = true
                        VC.waitingView.isHidden = true
                        Alerts.showErrorAlert(VC: VC, message: "Отсутствует соединение с сервером")
                    default:
                        VC.activityIndicator.stopAnimating()
                        VC.waitingLabel.isHidden = true
                        VC.waitingView.isHidden = true
                        Alerts.showErrorAlert(VC: VC, message: "Отсутствует соединение с сервером")
                    }
                } else {
                    VC.activityIndicator.stopAnimating()
                    VC.waitingLabel.isHidden = true
                    VC.waitingView.isHidden = true
                    NSLog ("modifiedString.error == nil, performing showCheckSegue")
                    VC.performSegue(withIdentifier: "showCheckSegue", sender: self)
                    print("showCheckSegue performed")
                }
            case .error(let error):
                print(error)
                NSLog ("case error: " + error.localizedDescription)
            }
        }
    }
    
    //Если чек уже существует, проверяем, загружен он или нет.
    //--Если загружен, возвращаем объект QrStringInfoObject()
    //--Если не загружен, пробуем загрузить.
    static func getStringInfo(VC: ScanViewController, token: NotificationToken?, qrStringInfo: String) {
        print("starting getStringInfo")
        NSLog("starting getStringInfo")
        let userId = UserDefaults.standard.string(forKey: "user")
        var realmQrString = QrStringInfoObject()
        
        do {
            let realm = try Realm()
            let user = realm.object(ofType: User.self, forPrimaryKey: userId)
            realmQrString = (user?.checks.filter("qrString = %@", qrStringInfo).first)!
        } catch {
            print (error)
            NSLog ("get realmQrString: error" + error.localizedDescription)
        }
        
        if (realmQrString.jsonString != nil && realmQrString.jsonString != "null") {
            VC.addedString = realmQrString
            VC.activityIndicator.stopAnimating()
            NSLog ("realmQrString is not empty, performing qrResult segue")
            VC.performSegue(withIdentifier: "qrResult", sender: nil)
        }
        else {
            NSLog ("realmQrString is empty, trying to load data")
            RequestService.loadData(receivedString: qrStringInfo)
            RealmServices.getStringFromRealm(VC: VC)
        }
        
    }

}
