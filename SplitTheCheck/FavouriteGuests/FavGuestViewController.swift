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
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView?.rowHeight = 50


        self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.navigationItem.rightBarButtonItem?.title = "Изменить"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            let realm = try Realm()
            realm.beginWrite()
            let user = realm.objects(User.self).first
            if user?.guests != nil {
                self.favouriteGuests = (user?.guests)!
            }
            try realm.commitWrite()
            print(realm.configuration.fileURL as Any)
            print ("View will appear: fav guests: \(self.favouriteGuests)")
            tableView.reloadData()
        } catch {
            print(error.localizedDescription)
        }
        
//        syncTableWithRealm()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return favouriteGuests.count+1
    }

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

//    func syncTableWithRealm() {
//        guard let realm = try? Realm() else {return}
//        let user = realm.objects(User.self).first
//        let realmFavouriteGuests = user?.guests
//        token = realmFavouriteGuests?.observe{[weak self] (changes: RealmCollectionChange) in
//            guard let tableView  =  self?.tableView else {return}
//            switch changes {
//            case .initial:
//                tableView.reloadData()
//                break
//            case .update(_, let deletions, let insertions, let modifications):
//                tableView.beginUpdates()
//                print("insertions: \(insertions)")
//                tableView.insertRows(at: insertions.map({IndexPath(row: $0, section: 0)}), with: .automatic)
//                print ("deletions: \(deletions)")
//                tableView.deleteRows(at: deletions.map({IndexPath(row: $0, section: 0)}), with: .automatic)
//                print ("modifications: \(modifications)")
//                tableView.reloadRows(at: modifications.map({IndexPath(row: $0, section: 0)}), with: .automatic)
//                tableView.endUpdates()
////                print (self?.favouriteGuests)
//                break
//            case .error(let error):
//                fatalError("\(error)")
//                break
//            }
//        }
//    }
    
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let view = UIView()
//
//        view.backgroundColor = UIColor(red:0.81, green:0.85, blue:0.97, alpha:1.0)
//        return view
//    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if indexPath.row < favouriteGuests.count {
            return .delete
        } else {
            return .none
        }
    }
    

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let guestToDelete = favouriteGuests[indexPath.row]
        
        if editingStyle == .delete {
            do {
                let realm = try Realm()
                realm.beginWrite()
                favouriteGuests.remove(at: indexPath.row)
                realm.delete(guestToDelete)
                try realm.commitWrite()
                tableView.reloadData()
            } catch {
                print (error.localizedDescription)
            }
            
            
            // Delete the row from the data source
            //tableView.deleteRows(at: [indexPath], with: .fade)
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
        } catch {
            print (error.localizedDescription)
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
