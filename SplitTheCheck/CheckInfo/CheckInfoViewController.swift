//
//  ViewControllerResult.swift
//  SplitTheCheck
//
//  Created by Anya on 26/12/2017.
//  Copyright © 2017 Anna Zhulidova. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import RealmSwift


class CheckInfoViewController: UIViewController, ResultCellDelegate {

    @IBOutlet weak var addGuest: CustomButton!
    @IBOutlet weak var checkTableView: UITableView!
    
//    let requestResult = RequestService()
    var parentString = QrStringInfoObject()
    var items = [[CheckInfoObject]]()
    var selectedItems: [CheckInfoObject] = []
    var guests = [GuestInfoObject]()
    var totalSum = [Double]()
    var guestSum = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print ("viewDidLoad")
        
        self.checkTableView?.rowHeight = 60
        self.tabBarController?.tabBar.isHidden = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveTheCheck))
//        tableView.delegate = self
        addGuest.titleLabel?.textAlignment = .center
        addGuest.titleLabel?.text = "Выберите позиции"
        
        do {
            let realm = try Realm()
            print (parentString.qrString)
            let realmItems = realm.objects(CheckInfoObject.self).filter("%@ IN parent", parentString).sorted(byKeyPath: "sectionId")
            var realItems = [CheckInfoObject]()
            for item in Array(realmItems) {
                let copyItem = item.copyItem()
                realItems.append(copyItem)
            }
            self.items = realItems.reduce([[CheckInfoObject]]()) {
                guard var last = $0.last else { return [[$1]] }
                var collection = $0
                if last.first!.sectionId == $1.sectionId {
                    last += [$1]
                    collection[collection.count - 1] = last
                } else {
                    collection += [[$1]]
                }
                return collection
            }
            
            for item in items {
                guests.append(GuestInfoObject(name: (item.first?.sectionName)!))
                totalSum.append(item.reduce(0){$0 + round(100*$1.price*$1.totalQuantity)/100})
            }
            
//                groupItems(items: realmItems)
            print("items grouped")
//            print ("Items : \(items)")
        } catch {
            print (error)
        }
        print ("total sum")
 //       self.totalSum[0] = items[0].reduce(0){$0 + round(100*$1.price*$1.totalQuantity)/100}
        self.checkTableView?.reloadData()
        print ("Items : \(items)")
        
        
    }
    
//    func groupItems(items: Results<CheckInfo>) -> [[CheckInfo]] {
//        let groupedItems = items.reduce([[CheckInfo]]()) {
//            guard var last = $0.last else { return [[$1]] }
//            var collection = $0
//            if last.first!.sectionId == $1.sectionId {
//                last += [$1]
//                collection[collection.count - 1] = last
//            } else {
//                collection += [[$1]]
//            }
//            return collection
//        }
//        return groupedItems
//    }

    override func viewWillAppear(_ animated: Bool) {
        if guestSum != 0 {
            addGuest.titleLabel?.text = "\(guestSum)"
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if guestSum != 0 {
            print ("view did disappear")
            addGuest.titleLabel?.text = "\(guestSum)"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension CheckInfoViewController: UITableViewDataSource, UITableViewDelegate {
    //количество секций
    func  numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    //количество строк в секции
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].count
    }
    
    //заголовок секции
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sectionHeader") as! HeaderCell
        
        cell.sectionTitle.text = guests[section].name
        cell.totalSum.text = "\(totalSum[section])"
        
        return cell.contentView
    }
    
    //конфигурация ячейки
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemInfo", for: indexPath) as! CheckInfoCell
        cell.delegate = self
        
        cell.configure(item: items[indexPath.section][indexPath.row], section: indexPath.section)

        return cell
    }
    
    //изменение количества выбранных единиц товара
    func amountTapped(_ cell: CheckInfoCell) {
        let indexPath = self.checkTableView.indexPath(for: cell)!
        let item = items[indexPath.section][indexPath.row]
        
        let myQuantityOld = item.myQuantity
        
        if myQuantityOld == 0 {
            checkTableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            self.tableView(checkTableView, didSelectRowAt: indexPath)
        } else {
            item.myQuantity = myQuantityOld % Int(item.totalQuantity) + 1
            item.myQtotalQ = "\(item.myQuantity)/\(Int(item.totalQuantity))"
            
            cell.itemAmount.text = item.myQtotalQ
            
            guestSum += Double(item.myQuantity-myQuantityOld)*item.price
            addGuest.titleLabel?.text = "\(guestSum)"
        }
    }
    
    //высота заголовка секции
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
        
    }
    
    //выделение ячейки. Устанавливаем количество выбранных единиц товара = 1
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as! CheckInfoCell
        let item = items[indexPath.section][indexPath.row]
        print("choose: \(item.myQtotalQ)")
        
        item.myQuantity += 1
        guestSum += Double(item.myQuantity)*item.price
        
        if item.totalQuantity == 1 {
            item.myQtotalQ = "1"
        } else {
            item.myQtotalQ = "\(item.myQuantity)/\(Int(item.totalQuantity))"
        }
        cell.itemAmount.text = item.myQtotalQ
        selectedItems.append(item)
        print("appended, total \(selectedItems.count)")
        
        addGuest.titleLabel?.text = "\(guestSum)"
        
        
    }
    
    //снятие выделения ячейки.  Устанавливаем количество выбранных единиц товара = totalQuantity
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let deselectedCell = tableView.cellForRow(at: indexPath) as! CheckInfoCell
        let item = items[indexPath.section][indexPath.row]
        
        if(selectedItems.contains(item)){
            print("contains")
            guestSum -= Double(item.myQuantity)*item.price
            addGuest.titleLabel?.text = "\(guestSum)"
            item.myQuantity = 0
            
            let index = selectedItems.index(of: item)
            selectedItems.remove(at: index!)
            deselectedCell.itemAmount.text = "\(Int(item.totalQuantity))"
            print("removed, total  \(selectedItems.count)")
        } else {
            print("not removed, total  \(selectedItems.count)")
        }
        
        if selectedItems.isEmpty {
            addGuest.titleLabel?.text = "Выберите позиции"
        }
    }
    
    //удаляем запись
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if indexPath.section == 0 {
            return .none
        } else {
            return .delete
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("delete")
            let item = items[indexPath.section][indexPath.row]
            item.printInfo()
            
            if items[0].contains(where: {$0 == item}) {
                print("Check contains item")
                
                let itemInCheck = items[0].first(where: {$0 == item})
                let index = items[0].index(of: itemInCheck!)
                items[0][index!].totalQuantity += item.totalQuantity
                items[0][index!].myQuantity = 0
                items[0][index!].myQtotalQ = "\(Int(items[0][index!].totalQuantity))"
                print(items[0][index!].totalQuantity)
                
            } else {
                print ("Check doesn't contain item")
                
                items[0].append(item)
                items[0].sort(by: {$0.id < $1.id})
                
                checkTableView.beginUpdates()
                checkTableView.insertRows(at: [IndexPath(row: items[0].count-1, section:0)], with: .none)
                checkTableView.endUpdates()
            }
            
            items[indexPath.section].remove(at: indexPath.row)
            totalSum[indexPath.section] -= item.totalQuantity*item.price
            totalSum[0] += item.totalQuantity*item.price
            checkTableView.deleteRows(at: [indexPath], with: .left)
            
            if items[indexPath.section].count == 0 {
                items.remove(at: indexPath.section)
                guests.remove(at: indexPath.section)
                totalSum.remove(at: indexPath.section)
            }
            checkTableView.reloadData()
        }
    }
}

extension CheckInfoViewController {
    //добавляем favouriteGuest на экран с чеком по нажатию на ячейку или кнопку +
    @IBAction func addGuestToCheck (segue: UIStoryboardSegue) {
        if segue.identifier == "addFavouriteGuestToCheck" {
            let guestViewCotroller = segue.source as! CheckGuestsViewController
//            let resultViewController = segue.destination as! ResultViewController
            
            if let indexPath = guestViewCotroller.tableView.indexPathForSelectedRow {
                let guest = guestViewCotroller.favouriteGuests[indexPath.row]
                guests.append(guest)
                
                addNewSection(sectionName: guest.name)
            }
        } else if  segue.identifier == "addNewGuestToCheck" {
            let guestViewCotroller = segue.source as! CheckGuestsViewController
            //            let resultViewController = segue.destination as! ResultViewController
            
            let guest = guestViewCotroller.newGuest
            print(guest.name)
            guests.append(guest)
                
            addNewSection(sectionName: guest.name)
        }
    }
    
    //добавление секции с гостем
    func addNewSection(sectionName: String) {
        var newSectionItems = [CheckInfoObject]()
        let sectionNo = items.count
        
        for item in selectedItems {
            newSectionItems.append(CheckInfoObject(sectionId: sectionNo, sectionName: sectionName, id: item.id, name: item.name, initialQuantity: item.initialQuantity, totalQuantity: Double(item.myQuantity), price: item.price))
            print("new item id: \(newSectionItems.last!.id)")
            
            let index = items[0].index(of: item)
            if item.totalQuantity == 1 {
                items[0].remove(at: index!)
            } else {
                items[0][index!].totalQuantity -= Double(items[0][index!].myQuantity)
            }
        }
        
        items.append(newSectionItems)
        selectedItems.removeAll()
        totalSum[0] -= guestSum
        totalSum.append(guestSum)
        guestSum = 0
        
        for item in items[0] {
            item.myQuantity = 0
            item.myQtotalQ = "\(Int(item.totalQuantity))"
        }
        
        addGuest.titleLabel?.text = "Выберите позиции"
        checkTableView.reloadData()
    }
    
    //сохранение чека
    @objc func saveTheCheck() {
        var itemsToRealm: [CheckInfoObject] = []
        
        for section in items {
            for item in section {
                let copyItem = item.copyItem()
                itemsToRealm.append(copyItem)
            }
        }
        do {
            let realm = try Realm()
            realm.beginWrite()
//            parentString.checkItems.removeAll()
            let oldCheck = realm.objects(CheckInfoObject.self).filter("%@ IN parent", parentString).sorted(byKeyPath: "sectionId")
            realm.delete(oldCheck)
            for item in itemsToRealm {
               parentString.checkItems.append(item)
            }
            try realm.commitWrite()
        } catch {
            print(error)
        }
    }
}
