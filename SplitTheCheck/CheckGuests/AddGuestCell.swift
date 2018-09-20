//
//  AddGuestCell.swift
//  SplitTheCheck
//
//  Created by Anya on 17/01/2018.
//  Copyright © 2018 Anna Zhulidova. All rights reserved.
//

import UIKit
import RealmSwift

protocol addGuestDelegate {
    func addNewGuest (_ cell: AddGuestCell)
//    func addToFavourites (_ cell: AddGuestCell)
}

class AddGuestCell: UITableViewCell, UITextFieldDelegate {
    @IBOutlet weak var guestName: UITextField! {
        didSet {guestName.delegate = self}
    }
    @IBOutlet weak var addGuestBtn: UIButton!
    
    
    var delegate = CheckGuestsViewController()
//    var delegateVC = CheckGuestsViewController()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func addGuestBtnTap(_ sender: CustomButton) {
        delegate.addNewGuest(self)
        print ("+ pressed")
    }
//    @IBAction func addToFavouritesBtnTap(_ sender: CustomButton) {
//        delegate?.addToFavourites(self)
//        print ("star pressed")
//    }
    
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
            self.delegate.tableView.reloadData()
            
            self.guestName.text = ""
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return false
    }

}
