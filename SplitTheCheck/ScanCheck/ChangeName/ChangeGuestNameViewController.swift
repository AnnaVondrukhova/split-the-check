//
//  ChangeGuestNameViewController.swift
//  SplitTheCheck
//
//  Created by Anya on 24/09/2018.
//  Copyright © 2018 Anna Vondrukhova. All rights reserved.
//

import UIKit
import RealmSwift

class ChangeGuestNameViewController: UITableViewController {
    
    var favouriteGuests = List<GuestInfoObject>()
    var newGuest = GuestInfoObject(name: "Гость 1")
    var sectionNo = 0
    let userId = UserDefaults.standard.string(forKey: "user")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView?.rowHeight = 50
        self.tabBarController?.tabBar.isHidden = true
        
        
        print(favouriteGuests)
        NSLog ("ChangeGuestNameVC did load")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            let realm = try Realm()
            realm.beginWrite()
            let user = realm.object(ofType: User.self, forPrimaryKey: self.userId)
            self.favouriteGuests = (user?.guests)!
            try realm.commitWrite()
            print(realm.configuration.fileURL as Any)
            NSLog("get favourite guests: success")
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
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return favouriteGuests.count + 1
    }
    
    //конфигурация ячейки
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row < favouriteGuests.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "favouriteGuest", for: indexPath) as! FavGuestNameCell
            cell.delegate = self
            
            cell.guestName.text = favouriteGuests[indexPath.row].name
            cell.setTag(tag: indexPath.row)
            cell.guestId = favouriteGuests[indexPath.row].id
            print ("cell tag: \(cell.guestName.tag)")
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addGuest") as! AddGuestNameCell
            cell.delegate = self
            cell.selectionStyle = .none
            return cell
            
        }
    }

}
