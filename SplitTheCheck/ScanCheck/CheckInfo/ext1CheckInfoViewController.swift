//
//  ext1CheckInfoViewController.swift
//  SplitTheCheck
//
//  Created by Anya on 09/10/2018.
//  Copyright © 2018 Anna Zhulidova. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import RealmSwift
import MessageUI
import QuickLook

//extension для добавления новой секции
extension CheckInfoViewController {
    
    //добавляем favouriteGuest на экран с чеком по нажатию на ячейку или кнопку +
    @IBAction func addGuestToCheck (segue: UIStoryboardSegue) {
        if segue.identifier == "addFavouriteGuestToCheck" {
            let guestViewCotroller = segue.source as! CheckGuestsViewController
            
            if let indexPath = guestViewCotroller.tableView.indexPathForSelectedRow {
                let guest = GuestInfoObject(name: guestViewCotroller.favouriteGuests[indexPath.row].name)
                //если такой гость уже существует, добавляем позиции к нему.
                //если гость еще не существует, добавляем новую секцию
                if guests.contains(where: {$0.name == guest.name}){
                    let sectionNo = guests.index(of: guests.first(where: {$0.name == guest.name})!)
                    addToSection(sectionNo: sectionNo!, sectionName: guest.name)
                } else {
                    guests.append(guest)
                    addNewSection(sectionName: guest.name)
                }
            }
        } else if segue.identifier == "addNewGuestToCheck" {
            let guestViewCotroller = segue.source as! CheckGuestsViewController
            
            let guest = guestViewCotroller.newGuest
            print(guest.name)
            guests.append(guest)
            
            addNewSection(sectionName: guest.name)
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
        
        addGuest.titleLabel?.text = "Выберите позиции"
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
            if !item.isCountable || (item.totalQuantity == 1) {
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
        
        addGuest.titleLabel?.text = "Выберите позиции"
        checkTableView.reloadData()
        NSLog ("added to existing guest section")
    }
    
    //изменяем имя гостя
    @IBAction func changeGuestName (segue: UIStoryboardSegue) {
        if segue.identifier == "changeNameToFavourite" {
            let guestNameVC = segue.source as! ChangeGuestNameViewController
            let sectionNo = guestNameVC.sectionNo
            
            if let indexPath = guestNameVC.tableView.indexPathForSelectedRow {
                print ("changing name to \(guestNameVC.favouriteGuests[indexPath.row].name)")
                do {
                    let realm = try! Realm()
                    realm.beginWrite()
                    guests[sectionNo].name = guestNameVC.favouriteGuests[indexPath.row].name
                    for item in items[sectionNo] {
                        item.sectionName = guestNameVC.favouriteGuests[indexPath.row].name
                    }
                    try realm.commitWrite()
                    NSLog("changing section name to favourite: success")
                } catch {
                    print (error)
                    NSLog("changing section name to favourite: error" + error.localizedDescription)
                }
                checkTableView.reloadData()
            }
        } else if segue.identifier == "changeNameToNew" {
            let guestNameVC = segue.source as! ChangeGuestNameViewController
            let sectionNo = guestNameVC.sectionNo
            let guest = guestNameVC.newGuest
            
            print ("changing name to \(guest.name)")
            do {
                let realm = try! Realm()
                realm.beginWrite()
                guests[sectionNo].name = guest.name
                for item in items[sectionNo] {
                    item.sectionName = guest.name
                }
                try realm.commitWrite()
                NSLog("changing section name to new: success")
            } catch {
                print (error)
                NSLog("changing section name to new: error" + error.localizedDescription)
            }
            checkTableView.reloadData()
        }
    }
}
