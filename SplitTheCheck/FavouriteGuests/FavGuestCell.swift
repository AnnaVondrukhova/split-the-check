//
//  FavGuestCell.swift
//  SplitTheCheck
//
//  Created by Anya on 20/02/2018.
//  Copyright © 2018 Anna Zhulidova. All rights reserved.
//

import UIKit
import RealmSwift

class FavGuestCell: UITableViewCell {

    @IBOutlet weak var favGuestPhoto: UIImageView!
    @IBOutlet weak var favGuestChar: UILabel!
    @IBOutlet weak var favGuestName: UITextField! {
        didSet {favGuestName.delegate = self}
    }
    
    
    
    var delegate = FavGuestViewController()
    var guestId = ""
    var isNew = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {


        // Configure the view for the selected state
    }
    
    func setTag(tag: Int) {
        favGuestName.tag = tag
    }
    
    func configure(guest: GuestInfoObject) {
        favGuestName.text = guest.name
        favGuestChar.text = String(guest.name.uppercased().first ?? " ")
        
        favGuestPhoto.image = nil
        favGuestPhoto.backgroundColor = UIColor(red:0.28, green:0.36, blue:0.72, alpha:1.0)
        favGuestPhoto.layer.cornerRadius = favGuestPhoto.frame.width/2
        favGuestPhoto.clipsToBounds = true
        self.isNew = false
//        guestId = guest.id
    }
    
    func configureDefault() {
        favGuestName.text = ""
        favGuestChar.text = ""
        
        favGuestPhoto.backgroundColor = nil
        favGuestPhoto.image = UIImage(named: "add1")
        favGuestPhoto.layer.cornerRadius = favGuestPhoto.frame.width/2
        favGuestPhoto.clipsToBounds = true
        self.isNew = true
    }

}

extension FavGuestCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        print ("****** did end editing")
        if !isNew {
            do {
                let realm = try Realm()
                realm.beginWrite()
                print (guestId)
                let guest = realm.object(ofType: GuestInfoObject.self, forPrimaryKey: guestId)
                print ("\(guest?.name), tag: \(favGuestName.tag)")
                guest?.name = favGuestName.text!
                try realm.commitWrite()
                print ("name edited")
            } catch {
                print (error.localizedDescription)
            }
        } else {
            do {
                let realm = try Realm()
                realm.beginWrite()
                if favGuestName.text! != nil && favGuestName.text! != "" {
                    let newGuest = GuestInfoObject(name: favGuestName.text!)
                    self.delegate.favouriteGuests.append(newGuest)
//                    realm.add(newGuest)
                    print ("new name added: \(favGuestName.text!)")
                    print (self.delegate.favouriteGuests.count)
                }
                try realm.commitWrite()
                self.delegate.tableView.reloadData()
                
                self.favGuestName.text = ""
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        
        if let nextField = textField.superview?.superview?.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
            print ("move to next field: \(nextField.tag)")
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
}
