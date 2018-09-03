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
        do {
            //            Realm.Configuration.defaultConfiguration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
            //            print("configuration changed")
            let realm = try Realm()
            realm.beginWrite()
            realm.add(string, update: true)
            print ("added string to Realm")
            try realm.commitWrite()
            print(realm.configuration.fileURL as Any)
        } catch {
            print(error)
        }
    }
    
    //Нотификация о добавлении данных в базe для ScanViewController.
    //если была добавлена строка, записываем ее в addedString. Если в ней есть ошибка, выдаем алерт с ошибкой.
    //если ошибки нет, передаем полученную строку на CheckInfoViewController и переходим туда
    static func getStringFromRealm(VC: ScanViewController) {
        print ("getStringFromRealm for ScanViewController")
        guard let realm = try? Realm() else {return}
        VC.storedChecks = realm.objects(QrStringInfoObject.self)
        VC.token = VC.storedChecks?.observe {(changes: RealmCollectionChange) in
            switch changes {
            case .initial ( _):
                print ("initial results downloaded")
            case .update(_, _, let insertions, let modifications):
                print("insertions: \(insertions)")
                print("modifications: \(modifications)")
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
                    switch  VC.addedString?.error {
                    case "403":
                        VC.activityIndicator.stopAnimating()
                        VC.activityIndicator.isHidden = true
                        VC.waitingLabel.isHidden = true
                        Alerts.authErrorAlert(VC: VC, message: "Неверный пользователь или пароль. Требуется повторная авторизация")
                    case "406":
                        VC.activityIndicator.stopAnimating()
                        VC.activityIndicator.isHidden = true
                        VC.waitingLabel.isHidden = true
                        Alerts.showErrorAlert(VC: VC, message: "Чек не найден")
                    case "202":
                        print ("Ошибка 202, повторяем запрос...")
                        usleep(500000)
                        RequestService.loadData(receivedString: VC.qrString)
                    case "500":
                        VC.activityIndicator.stopAnimating()
                        VC.activityIndicator.isHidden = true
                        VC.waitingLabel.isHidden = true
                        Alerts.showErrorAlert(VC: VC, message: "Отсутствует соединение с сервером")
                    default:
                        VC.activityIndicator.stopAnimating()
                        VC.activityIndicator.isHidden = true
                        VC.waitingLabel.isHidden = true
                        Alerts.showErrorAlert(VC: VC, message: "Отсутствует соединение с сервером")
                    }
                    //!!ВОПРОС!! Переходить ли на страницу со списком чеков?
                } else {
                    VC.activityIndicator.stopAnimating()
                    VC.performSegue(withIdentifier: "qrResult", sender: nil)
                    print("qrResult segue performed from GetStringFromRealm")
                }
            case .error(let error):
                print(error)
            }
        }
    }
    
    
    //Нотификация об обновлении данных в базе для AllChecksViewController
    //Если строка была обновлена, записываем ее в modifiedString. Если в ней есть ошибка, выдаем алерт с ошибкой.
    //если ошибки нет, передаем полученную строку на CheckInfoViewController и переходим туда
    static func getStringFromRealm(VC: AllChecksViewController, qrString: String) {
        print ("getStringFromRealm for AllChecksViewController")
        guard let realm = try? Realm() else {return}
        var storedChecks: Results<QrStringInfoObject>?
        storedChecks = realm.objects(QrStringInfoObject.self)
        VC.token = storedChecks?.observe {(changes: RealmCollectionChange) in
            switch changes {
            case .initial ( _):
                print ("initial results downloaded")
            case .update(_, _, let insertions, let modifications):
                print("insertions: \(insertions)")
                print("modifications: \(modifications)")
                VC.modifiedString = (VC.storedChecks?[modifications[0]])!
                if VC.modifiedString.error != nil {
                    switch  VC.modifiedString.error {
                    case "403":
                        VC.activityIndicator.stopAnimating()
                        VC.activityIndicator.isHidden = true
                        VC.waitingLabel.isHidden = true
                        Alerts.authErrorAlert(VC: VC, message: "Неверный пользователь или пароль. Требуется повторная авторизация")
                    case "406":
                        VC.activityIndicator.stopAnimating()
                        VC.activityIndicator.isHidden = true
                        VC.waitingLabel.isHidden = true
                        Alerts.showErrorAlert(VC: VC, message: "Чек не найден")
                    case "202":
                        print ("Ошибка 202, повторяем запрос...")
                        usleep(500000)
                        RequestService.loadData(receivedString: qrString)
                    case "500":
                        VC.activityIndicator.stopAnimating()
                        VC.activityIndicator.isHidden = true
                        VC.waitingLabel.isHidden = true
                        Alerts.showErrorAlert(VC: VC, message: "Отсутствует соединение с сервером")
                    default:
                        VC.activityIndicator.stopAnimating()
                        VC.activityIndicator.isHidden = true
                        VC.waitingLabel.isHidden = true
                        Alerts.showErrorAlert(VC: VC, message: "Отсутствует соединение с сервером")
                    }
                } else {
                    VC.activityIndicator.stopAnimating()
                    VC.performSegue(withIdentifier: "showCheckSegue", sender: nil)
                    print("showCheckSegue performed")
                }
            case .error(let error):
                print(error)
            }
        }
    }
    
    //Если чек уже существует, проверяем, загружен он или нет.
    //--Если загружен, возвращаем объект QrStringInfoObject()
    //--Если не загружен, пробуем загрузить.
    static func getStringInfo(VC: ScanViewController, token: NotificationToken?, qrStringInfo: String) {
        print("starting getStringInfo")
        var realmQrString = QrStringInfoObject()
        
        do {
            let realm = try Realm()
            realmQrString = realm.object(ofType: QrStringInfoObject.self, forPrimaryKey: qrStringInfo)!
        } catch {
            print (error)
        }
        
        if (realmQrString.jsonString != nil && realmQrString.jsonString != "null") {
            VC.addedString = realmQrString
            VC.performSegue(withIdentifier: "qrResult", sender: nil)
        }
        else {
            RequestService.loadData(receivedString: qrStringInfo)
            RealmServices.getStringFromRealm(VC: VC)
        }
        
    }

}
