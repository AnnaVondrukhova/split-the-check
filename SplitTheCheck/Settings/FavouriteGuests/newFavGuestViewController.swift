//
//  newFavGuestViewController.swift
//  SplitTheCheck
//
//  Created by Anya on 23/02/2018.
//  Copyright © 2018 Anna Zhulidova. All rights reserved.
//

import UIKit
import RealmSwift

class newFavGuestViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var favouriteGuests = [GuestInfo]()
    var token: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print ("************** view *************")
        self.tableView?.rowHeight = 50
        // Do any additional setup after loading the view.
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        do {
//            let realm = try Realm()
//            realm.beginWrite()
//            let favouriteGuests = realm.objects(GuestInfo.self)
//            self.favouriteGuests = Array(favouriteGuests)
//            try realm.commitWrite()
//            print(realm.configuration.fileURL as Any)
//        } catch {
//            print(error.localizedDescription)
//        }
//        
//        syncTableWithRealm()
//        
//    }
    
    func syncTableWithRealm() {
        guard let realm = try? Realm() else {return}
        let realmFavouriteGuests = realm.objects(GuestInfo.self)
        token = realmFavouriteGuests.observe{[weak self] (changes: RealmCollectionChange) in
            guard let tableView  =  self?.tableView else {return}
            switch changes {
            case .initial:
                tableView.reloadData()
                break
            case .update(_, let deletions, let insertions, let modifications):
                tableView.beginUpdates()
                print("insertions: \(insertions)")
                tableView.insertRows(at: insertions.map({IndexPath(row: $0, section: 0)}), with: .automatic)
                print ("deletions: \(deletions)")
                tableView.deleteRows(at: deletions.map({IndexPath(row: $0, section: 0)}), with: .automatic)
                print ("modifications: \(modifications)")
                tableView.reloadRows(at: modifications.map({IndexPath(row: $0, section: 0)}), with: .automatic)
                tableView.endUpdates()
//                print (self?.favouriteGuests)
                break
            case .error(let error):
                fatalError("\(error)")
                break
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension newFavGuestViewController:  UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        print ("************** section *************")
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print ("************** rows *************")
//        return favouriteGuests.count+1
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "favGuestCell", for: indexPath) as! FavGuestCell
//        cell.delegate = self
//
//        if indexPath.row < favouriteGuests.count {
//            cell.configure(guest: favouriteGuests[indexPath.row])
//            cell.setTag(tag: indexPath.row)
//            cell.guestId = favouriteGuests[indexPath.row].id
//            print ("cell tag: \(cell.favGuestName.tag)")
//        } else {
//            cell.configureDefault()
//            cell.setTag(tag: indexPath.row)
//            print ("cell tag: \(cell.favGuestName.tag)")
//        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "newCell", for: indexPath) as! NewCell
        cell.selectionStyle = .none
        
        return cell
    }
}
