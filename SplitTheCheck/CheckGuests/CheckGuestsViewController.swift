//
//  GuestViewController.swift
//  SplitTheCheck
//
//  Created by Anya on 17/01/2018.
//  Copyright © 2018 Anna Zhulidova. All rights reserved.
//

import UIKit
import RealmSwift

class CheckGuestsViewController: UITableViewController, addGuestDelegate  {
    
    var favouriteGuests = List<GuestInfoObject>()
    var newGuest = GuestInfoObject(name: "Гость 1")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView?.rowHeight = 50
        self.tabBarController?.tabBar.isHidden = true
    
        
        
//        if let favouriteGuestsData = UserDefaults.standard.object(forKey: "favouriteGuests") as? Data {
//            if let array = NSKeyedUnarchiver.unarchiveObject(with: favouriteGuestsData) as? [GuestInfo] {
//                self.favouriteGuests = array            }
//        } else {
//            favouriteGuests = [GuestInfo(name: "Я", favourite: true)]
//            let favouriteGuestsData = NSKeyedArchiver.archivedData(withRootObject: favouriteGuests)
//            UserDefaults.standard.set(favouriteGuestsData, forKey: "favouriteGuests")
//            UserDefaults.standard.synchronize()
//        }
        
        print(favouriteGuests)
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
//            Realm.Configuration.defaultConfiguration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
//            print("configuration changed")
            let realm = try Realm()
            realm.beginWrite()
            let user = realm.objects(User.self).first
            self.favouriteGuests = (user?.guests)!
            try realm.commitWrite()
            print(realm.configuration.fileURL as Any)
        } catch {
            print(error.localizedDescription)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return favouriteGuests.count + 1
    }

    //конфигурация ячейки
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row < favouriteGuests.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "favouriteGuest", for: indexPath) as! FavouriteGuestCell
            
            cell.guestName.text = favouriteGuests[indexPath.row].name
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addGuest") as! AddGuestCell
            cell.delegate = self
            cell.selectionStyle = .none
            return cell
            
        }
    }
    
 
//    //ячейка с добавлением нового гостя
//    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "addGuest") as! AddGuestCell
//        cell.delegate = self
//        cell.guestName.text = "Гость 1"
//        
//        return cell
//    }
    
    //добавляем нового гостя в guests по нажатию кнопки
    func addNewGuest(_ cell: AddGuestCell) {
        newGuest = GuestInfoObject(name: cell.guestName.text!)
        
//        if cell.guestName.text?.replacingOccurrences(of: " ", with: "") != "" {
//            do {
//                let realm = try Realm()
//                realm.beginWrite()
//                favouriteGuests.append(GuestInfoObject(name: cell.guestName.text!))
//                print ("fav guests: \(favouriteGuests)")
//                //                realm.add(newGuest, update: true)
//                try realm.commitWrite()
//            } catch {
//                print (error.localizedDescription)
//            }
//        }
        
//            let favouriteGuestsData = NSKeyedArchiver.archivedData(withRootObject: favouriteGuests)
//            UserDefaults.standard.set(favouriteGuestsData, forKey: "favouriteGuests")
//            print ("fav guests set:  \(favouriteGuests)")
//            UserDefaults.standard.synchronize()

    }
    
    //добавляем нового гостя в favouriteGuests по нажатию кнопки
//    func addToFavourites(_ cell: AddGuestCell) {
//        cell.addToFavouritesBtnState = !cell.addToFavouritesBtnState
//        
//        if cell.addToFavouritesBtnState == true {
//            cell.addToFavouritesBtn.setImage(UIImage(named: "starTrue"), for: .normal)
//        } else {
//            cell.addToFavouritesBtn.setImage(UIImage(named: "starFalse"), for: .normal)
//        }
//    }
}
