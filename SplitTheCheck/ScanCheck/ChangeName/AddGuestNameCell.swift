//
//  AddGuestNameCell.swift
//  SplitTheCheck
//
//  Created by Anya on 24/09/2018.
//  Copyright © 2018 Anna Vondrukhova. All rights reserved.
//

import UIKit
import RealmSwift

class AddGuestNameCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var guestName: UITextField! {
        didSet {guestName.delegate = self}
    }
    @IBOutlet weak var addGuestBtn: CustomButton!
    
    var delegate = ChangeGuestNameViewController()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func addGuestBtnTap(_ sender: Any) {
        delegate.newGuest = GuestInfoObject(name: self.guestName.text!)
        print ("+ pressed")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print ("****** did end editing")
        do {
            let realm = try Realm()
            realm.beginWrite()
            if guestName.text != nil && guestName.text?.replacingOccurrences(of: " ", with: "") != "" {
                let newGuest = GuestInfoObject(name: guestName.text!)
                self.delegate.favouriteGuests.append(newGuest)
                //                    realm.add(newGuest)
                print ("new name added: \(guestName.text!)")
                print (self.delegate.favouriteGuests.count)
            }
            try realm.commitWrite()
            NSLog ("add new favGuest: success")
            self.delegate.tableView.reloadData()
            
            self.guestName.text = ""
        } catch {
            print(error.localizedDescription)
            NSLog ("add new favGuest: error " + error.localizedDescription)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return false
    }
}
