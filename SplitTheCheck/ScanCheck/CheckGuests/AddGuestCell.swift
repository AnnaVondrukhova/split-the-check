//
//  AddGuestCell.swift
//  SplitTheCheck
//
//  Created by Anya on 17/01/2018.
//  Copyright © 2018 Anna Vondrukhova. All rights reserved.
//

import UIKit
import RealmSwift


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
    
    //добавляем нового гостя в guests по нажатию кнопки
    @IBAction func addGuestBtnTap(_ sender: CustomButton) {
        delegate.newGuest = GuestInfoObject(name: self.guestName.text!)
        print ("+ pressed")
        let guest = delegate.newGuest
        let guestType: GuestType = .new
        switch delegate.action {
        case .addGuest:
            delegate.delegate.addGuestToCheck(guestType: guestType, guest: guest)
            delegate.navigationController?.popViewController(animated: true)
        case .changeName:
            if delegate.delegate.guests.contains(where:{$0.name == guest.name}) {
                delegate.delegate.showGuestAlert(name: guest.name, fromSection: delegate.sectionNo, VC: delegate.self) { (sectionNo) in
                    if sectionNo == 0 {
                        print ("async?")
                        self.delegate.delegate.items.insert([], at: 0)
                        self.delegate.delegate.guests.insert(GuestInfoObject(name: "Не распределено"), at: 0)
                        self.delegate.delegate.totalSum.insert(0.0, at: 0)
                        self.delegate.delegate.isFolded.insert(false, at: 0)
                        
                        for section in self.delegate.delegate.items {
                            for item in section {
                                item.sectionId += 1
                            }
                        }
                    }
                    self.delegate.navigationController?.popViewController(animated: true)
                    self.delegate.delegate.checkTableView.reloadData()
                }
            } else {
                delegate.delegate.changeGuestName(sectionNo: delegate.sectionNo, guestType: guestType, guest: guest)
                delegate.navigationController?.popViewController(animated: true)
            }
        }
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
