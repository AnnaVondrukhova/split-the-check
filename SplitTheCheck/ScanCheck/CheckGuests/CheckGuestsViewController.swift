//
//  GuestViewController.swift
//  SplitTheCheck
//
//  Created by Anya on 17/01/2018.
//  Copyright © 2018 Anna Vondrukhova. All rights reserved.
//

import UIKit
import RealmSwift

enum ActionType {
    case addGuest
    case changeName
}

enum GuestType {
    case favourite
    case new
}

protocol CheckGuestsDelegate {
    func addGuestToCheck (guestType: GuestType, guest: GuestInfoObject)
    func changeGuestName (sectionNo: Int, guestType: GuestType, guest: GuestInfoObject)
}

class CheckGuestsViewController: UITableViewController  {
    
    var favouriteGuests = List<GuestInfoObject>()
    var newGuest = GuestInfoObject(name: "Гость 1")
    let userId = UserDefaults.standard.string(forKey: "user")
    var sectionNo = 0
    var action: ActionType = .addGuest
    var delegate: CheckInfoViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView?.rowHeight = 50
        self.tabBarController?.tabBar.isHidden = true
    
        print(favouriteGuests)
        NSLog ("CheckGuestsVC did load")
        
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "favouriteGuest", for: indexPath) as! FavouriteGuestCell
            cell.delegate = self
            
            cell.guestName.text = favouriteGuests[indexPath.row].name
            cell.setTag(tag: indexPath.row)
            cell.guestId = favouriteGuests[indexPath.row].id
            cell.selectionStyle = .none
            print ("cell tag: \(cell.guestName.tag)")
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addGuest") as! AddGuestCell
            cell.delegate = self
            cell.selectionStyle = .none
            return cell
            
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView.dequeueReusableCell(withIdentifier: "favouriteGuest") as? FavouriteGuestCell) != nil {
            let guest = favouriteGuests[indexPath.row]
            let guestType: GuestType = .favourite
            switch action {
            case .addGuest:
                delegate.addGuestToCheck(guestType: guestType, guest: guest)
                self.navigationController?.popViewController(animated: true)
            case .changeName:
                if delegate.guests.contains(where:{$0.name == guest.name}) {
                    delegate.showGuestAlert(name: guest.name, fromSection: sectionNo, VC: self) { (sectionNo) in
                        if sectionNo == 0 {
                            print ("async?")
                            self.delegate.items.insert([], at: 0)
                            self.delegate.guests.insert(GuestInfoObject(name: "Не распределено"), at: 0)
                            self.delegate.totalSum.insert(0.0, at: 0)
                            self.delegate.isFolded.insert(false, at: 0)
                            
                            for section in self.delegate.items {
                                for item in section {
                                    item.sectionId += 1
                                }
                            }
                        }
                        self.navigationController?.popViewController(animated: true)
                        self.delegate.checkTableView.reloadData()
                    }
                } else {
                    delegate.changeGuestName(sectionNo: sectionNo, guestType: .favourite, guest: guest)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
}
