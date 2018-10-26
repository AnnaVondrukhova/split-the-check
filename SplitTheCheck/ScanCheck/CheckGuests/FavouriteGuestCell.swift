//
//  FavouriteGuestCell.swift
//  SplitTheCheck
//
//  Created by Anya on 17/01/2018.
//  Copyright © 2018 Anna Zhulidova. All rights reserved.
//

import UIKit
import RealmSwift

class FavouriteGuestCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var guestName: CustomTextField! {
        didSet {guestName.delegate = self}
    }
    @IBOutlet weak var editBtn: UIButton!
    
    var delegate = CheckGuestsViewController()
    var guestId = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.isUserInteractionEnabled = true
        guestName.isUserInteractionEnabled = false
        guestName.font = UIFont.boldSystemFont(ofSize: 17)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setTag(tag: Int) {
        guestName.tag = tag
    }
    
    @IBAction func editBtnTap(_ sender: Any) {
        guestName.font = UIFont.systemFont(ofSize: 17)
        guestName.isUserInteractionEnabled = true
        guestName.becomeFirstResponder()
        
        editBtn.setImage(UIImage(named: "edit_now"), for: .normal)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //если после изменения имя окажется пустым - возвращаем имя как было (работает как в Reminders). Если нет - записываем изменения в базу
        if guestName.text?.replacingOccurrences(of: " ", with: "") == "" {
            do {
                let realm = try Realm()
                print (guestId)
                let guest = realm.object(ofType: GuestInfoObject.self, forPrimaryKey: guestId)
                print ("\(guest?.name), tag: \(guestName.tag)")
                guestName.text = guest?.name
                print ("undo typing")
                NSLog ("undo edit favGuest name: success")
            } catch {
                print (error.localizedDescription)
                NSLog ("undo edit favGuest name: error" + error.localizedDescription)
            }
        } else {
            do {
                let realm = try Realm()
                realm.beginWrite()
                print (guestId)
                let guest = realm.object(ofType: GuestInfoObject.self, forPrimaryKey: guestId)
                print ("\(guest?.name), tag: \(guestName.tag)")
                guest?.name = guestName.text!
                try realm.commitWrite()
                print ("name edited")
                NSLog ("edit favGuest name: success")
            } catch {
                print (error.localizedDescription)
                NSLog ("edit favGuest name: error" + error.localizedDescription)
            }
        }
        
        self.isUserInteractionEnabled = true
        
        guestName.isUserInteractionEnabled = false
        guestName.font = UIFont.boldSystemFont(ofSize: 17)
        
        editBtn.setImage(UIImage(named: "edit"), for: .normal)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.isUserInteractionEnabled = true
        
        guestName.isUserInteractionEnabled = false
        guestName.font = UIFont.boldSystemFont(ofSize: 17)
        
        editBtn.setImage(UIImage(named: "edit"), for: .normal)
        
        return false
    }

    
}
