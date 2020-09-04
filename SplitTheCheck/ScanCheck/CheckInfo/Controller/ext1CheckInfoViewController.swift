//
//  ext1CheckInfoViewController.swift
//  SplitTheCheck
//
//  Created by Anya on 09/10/2018.
//  Copyright © 2018 Anna Vondrukhova. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import RealmSwift
import MessageUI
import QuickLook

//extension для добавления новой секции
extension CheckInfoViewController: CheckGuestsDelegate {
    
    //добавляем favouriteGuest на экран с чеком по нажатию на ячейку или кнопку +
    func addGuestToCheck (guestType: GuestType, guest: GuestInfoObject) {
        //если позиции не были выбраны, гостя не добавляем
        if !selectedItems.isEmpty {
            switch guestType {
            case .favourite:
                //если такой гость уже существует, добавляем позиции к нему.
                //если гость еще не существует, добавляем новую секцию
                if guests.contains(where: {$0.name == guest.name}){
                    let sectionNo = guests.index(of: guests.first(where: {$0.name == guest.name})!)
                    addToSection(sectionNo: sectionNo!, sectionName: guest.name)
                } else {
                    guests.append(guest)
                    addNewSection(sectionName: guest.name)
                }
            case .new:
                if guest.name.replacingOccurrences(of: " ", with: "") == "" {
                    guest.name = "Гость"
                }
                print("guest name = " + guest.name)
                guests.append(guest)
                
                addNewSection(sectionName: guest.name)
            }
        } else {
            print ("No positions selected")
            NSLog ("addGuestToCheck: No positions selected")
        }
    }
    
    //добавление новой секции с гостем
    func addNewSection(sectionName: String) {
        //добавляем состояние isFolded для секции - false по умолчанию
        isFolded.append(false)
        
        var newSectionItems = [CheckInfoObject]()
        let sectionNo = items.count
        
        //создаем копии элементов из selectedItems и с новым порядковым номером секции
        for item in selectedItems {
            var itemQuantity = 0.0
            if item.isCountable {
                itemQuantity = Double(item.myQuantity)
            } else {
                itemQuantity = item.totalQuantity
            }
            newSectionItems.append(CheckInfoObject(sectionId: sectionNo, sectionName: sectionName, id: item.id, name: item.name, initialQuantity: item.initialQuantity, totalQuantity: itemQuantity, isCountable: item.isCountable, price: item.price, sum: item.sum*100))
            print("new item id: \(newSectionItems.last!.id)")
            
            //из общего чека удаляем товары, перешедшие к гостю, или уменьшаем их количество
            let index = items[0].index(of: item)
            if !item.isCountable || (item.totalQuantity == 1)||(items[0][index!].totalQuantity == Double(items[0][index!].myQuantity)) {
                items[0].remove(at: index!)
            } else {
                items[0][index!].totalQuantity -= Double(items[0][index!].myQuantity)
            }
        }
        
        //создаем новый элемент массива items, обнуляем список выделенных позиций и сумму гостя
        items.append(newSectionItems)
        selectedItems.removeAll()
        totalSum[0] -= guestSum
        totalSum.append(guestSum)
        guestSum = 0
        
        for item in items[0] {
            item.myQuantity = 0
            if item.isCountable {
                item.myQtotalQ = "\(Int(item.totalQuantity))"
            } else {
                item.myQtotalQ = "\(item.totalQuantity)"
            }
            
        }
        
        sumLabel.text = "0₽"
        checkTableView.reloadData()
        NSLog ("added new guest section")
    }
    
    //добавление позиций к существующей секции с гостем
    func addToSection(sectionNo: Int, sectionName: String) {
        var newItems = [CheckInfoObject]()
        
        //создаем копии элементов из selectedItems и с переданным в функцию порядковым номером секции
        for item in selectedItems {
            var itemQuantity = 0.0
            if item.isCountable {
                itemQuantity = Double(item.myQuantity)
            } else {
                itemQuantity = item.totalQuantity
            }
            newItems.append(CheckInfoObject(sectionId: sectionNo, sectionName: sectionName, id: item.id, name: item.name, initialQuantity: item.initialQuantity, totalQuantity: itemQuantity, isCountable: item.isCountable, price: item.price, sum: item.sum*100))
            print("new item id: \(newItems.last!.id)")
            
            //из общего чека удаляем товары, перешедшие к гостю, или уменьшаем их количество
            let index = items[0].index(of: item)
            if !item.isCountable || (item.totalQuantity == 1)||(items[0][index!].totalQuantity == Double(items[0][index!].myQuantity)) {
                items[0].remove(at: index!)
            } else {
                items[0][index!].totalQuantity -= Double(items[0][index!].myQuantity)
            }
        }
        
        //если такой товар у гостя уже есть - добавляем его количество. Если нет - добавляем новый товар
        for item in newItems {
            if items[sectionNo].contains(where: {$0.id == item.id}){
                let existingItem = items[sectionNo].first(where: {$0.id == item.id})
                existingItem?.totalQuantity += item.totalQuantity
                existingItem?.myQtotalQ = "\(Int((existingItem?.totalQuantity)!))"
                
            } else {
                items[sectionNo].append(item)
            }
        }
        
        selectedItems.removeAll()
        totalSum[0] -= guestSum
        totalSum[sectionNo] += guestSum
        guestSum = 0
        
        for item in items[0] {
            item.myQuantity = 0
            if item.isCountable {
                item.myQtotalQ = "\(Int(item.totalQuantity))"
            } else {
                item.myQtotalQ = "\(item.totalQuantity)"
            }
            
        }
        
        sumLabel.text = "0₽"
        checkTableView.reloadData()
        NSLog ("added to existing guest section")
    }
    
    //изменяем имя гостя
    func changeGuestName (sectionNo: Int, guestType: GuestType, guest: GuestInfoObject) {
        
        print ("changing name to \(guest.name)")
        guests[sectionNo].name = guest.name
        for item in items[sectionNo] {
            item.sectionName = guest.name
        }
        //если переименовывали нулевую секцию - вставляем ее обратно
        if sectionNo == 0 {
            items.insert([], at: 0)
            guests.insert(GuestInfoObject(name: "Не распределено"), at: 0)
            totalSum.insert(0.0, at: 0)
            isFolded.insert(false, at: 0)
            
            for section in items {
                for item in section {
                    item.sectionId += 1
                }
            }
        }
        
        checkTableView.reloadData()
        print("section name changed")
        NSLog("section name changed")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! CheckGuestsViewController
        if segue.identifier == "addGuestSegue" {
            print ("pressed \"Add guest\" button")
            controller.action = .addGuest
            controller.delegate = self
        }
        if segue.identifier == "changeGuestNameSegue" {
            if let button = sender as! UIButton? {
                print ("pressed button \(button.tag)")
                controller.sectionNo = button.tag
                controller.action = .changeName
                controller.delegate = self
            }
        }
    }
    
    //ошибка повтора гостя при переименовании секции
    func showGuestAlert(name: String, fromSection: Int, VC: CheckGuestsViewController, completion: @escaping  (Int) -> Void) {
        let alert = UIAlertController(title: "Гость уже существует", message: "Гость с именем \"\(name)\" уже есть в этом чеке. Добавить позиции к этому гостю?", preferredStyle: .alert)
        //если нажимаем Отмена, ничего не делаем
        let actionCancel = UIAlertAction(title: "Oтмена", style: .cancel, handler: {(action: UIAlertAction) in
            VC.tableView.reloadData()
        })
        
        //если выбираем Да, то переносим позиции к уже существующему гостю
        let actionOk = UIAlertAction(title: "Да", style: .default, handler: {(action: UIAlertAction) in
            let toSection = self.guests.index(of: self.guests.first(where: {$0.name == name})!)
            print("fromSection = \(fromSection)")
            for item in self.items[fromSection] {
                item.sectionId = toSection!
                item.sectionName = name
                self.items[toSection!].append(item)
            }
            
            self.totalSum[toSection!] += self.totalSum[fromSection]
            print ("\(self.totalSum[fromSection])")
            print ("\(self.totalSum[toSection!])")
            //удаляем опустевшую секцию и сдвигаем все последующие на 1 назад
            self.items.remove(at: fromSection)
            self.guests.remove(at:fromSection)
            self.totalSum.remove(at: fromSection)
            self.isFolded.remove(at:fromSection)
            
            for section in fromSection..<self.items.count {
                for item in self.items[section] {
                    item.sectionId -= 1
                }
            }
            
            completion (fromSection)
        })
        alert.addAction(actionOk)
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
    }
    
}
