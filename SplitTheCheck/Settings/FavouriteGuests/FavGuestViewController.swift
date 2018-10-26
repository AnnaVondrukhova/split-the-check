//
//  FavGuestViewController.swift
//  SplitTheCheck
//
//  Created by Anya on 20/02/2018.
//  Copyright © 2018 Anna Zhulidova. All rights reserved.
//

import UIKit
import RealmSwift

class FavGuestViewController: UITableViewController {

    var favouriteGuests = List<GuestInfoObject>()
    var token: NotificationToken?
    let userId = UserDefaults.standard.string(forKey: "user")
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView?.rowHeight = 44

        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.navigationItem.rightBarButtonItem?.title = "Изменить"
        NSLog ("FavGuestVC did load")
    }
    
    //при появлении контроллера получаем из базы список гостей
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            let realm = try Realm()
            realm.beginWrite()
            let user = realm.object(ofType: User.self, forPrimaryKey: self.userId)
            if user?.guests != nil {
                self.favouriteGuests = (user?.guests)!
            }
            try realm.commitWrite()
            print(realm.configuration.fileURL as Any)
            print ("View will appear: fav guests: \(self.favouriteGuests)")
            NSLog("get favourite guests: success")
            tableView.reloadData()
        } catch {
            print(error.localizedDescription)
            NSLog("get favourite guests: error " + error.localizedDescription)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return favouriteGuests.count+1
    }

    //конфигурация ячейки
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favGuestCell", for: indexPath) as! FavGuestCell
        cell.delegate = self
        
        if indexPath.row < favouriteGuests.count {
            cell.configure(guest: favouriteGuests[indexPath.row])
            cell.setTag(tag: indexPath.row)
            cell.guestId = favouriteGuests[indexPath.row].id
            print ("cell tag: \(cell.favGuestName.tag)")
        } else {
            cell.configureDefault()
            cell.setTag(tag: indexPath.row)
            print ("cell tag: \(cell.favGuestName.tag)")
        }
        
        cell.selectionStyle = .none
        
        return cell
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if indexPath.row < favouriteGuests.count {
            return .delete
        } else {
            return .none
        }
    }
    
    //удаляем гостя из списка
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let guestToDelete = favouriteGuests[indexPath.row]
        
        if editingStyle == .delete {
            do {
                let realm = try Realm()
                realm.beginWrite()
                favouriteGuests.remove(at: indexPath.row)
                realm.delete(guestToDelete)
                try realm.commitWrite()
                NSLog("Deleting guest: success")
                tableView.reloadData()
            } catch {
                print (error.localizedDescription)
                NSLog("Deleting guest: error" + error.localizedDescription)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let rowToMove = favouriteGuests[sourceIndexPath.row]
        
        do {
            let realm = try Realm()
            realm.beginWrite()
            favouriteGuests.remove(at: sourceIndexPath.row)
            favouriteGuests.insert(rowToMove, at: destinationIndexPath.row)
            try realm.commitWrite()
            print (favouriteGuests)
            NSLog("Moving guest: success")
        } catch {
            print (error.localizedDescription)
            NSLog("Moving guest: error" + error.localizedDescription)
        }
        
        tableView.reloadData()
    }
 
    override func setEditing (_ editing:Bool, animated:Bool)
    {
        super.setEditing(editing,animated:animated)
        if(self.isEditing)
        {
            self.editButtonItem.title = "Готово"
        }else
        {
            self.editButtonItem.title = "Изменить"
        }
    }


}
