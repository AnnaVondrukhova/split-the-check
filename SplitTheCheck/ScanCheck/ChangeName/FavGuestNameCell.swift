//
//  FavGuestNameCell.swift
//  SplitTheCheck
//
//  Created by Anya on 24/09/2018.
//  Copyright © 2018 Anna Zhulidova. All rights reserved.
//

import UIKit
import RealmSwift

class FavGuestNameCell: UITableViewCell, UITextFieldDelegate {
   
    @IBOutlet weak var guestName: CustomTextField! {
        didSet {guestName.delegate = self}
    }
    @IBOutlet weak var editBtn: UIButton!
    
    var delegate = ChangeGuestNameViewController()
    var guestId = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isUserInteractionEnabled = true
        guestName.isUserInteractionEnabled = false
        guestName.font = UIFont.boldSystemFont(ofSize: 17)
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setTag(tag: Int) {
        guestName.tag = tag
    }
    
    @IBAction func editBtnTap(_ sender: Any) {
//        self.isUserInteractionEnabled = false
        
        guestName.font = UIFont.systemFont(ofSize: 17)
        guestName.isUserInteractionEnabled = true
        guestName.becomeFirstResponder()
        
        editBtn.setImage(UIImage(named: "edit_now"), for: .normal)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        do {
            let realm = try Realm()
            realm.beginWrite()
            print (guestId)
            let guest = realm.object(ofType: GuestInfoObject.self, forPrimaryKey: guestId)
            print ("\(guest?.name), tag: \(guestName.tag)")
            guest?.name = guestName.text!
            try realm.commitWrite()
            print ("name edited")
        } catch {
            print (error.localizedDescription)
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
