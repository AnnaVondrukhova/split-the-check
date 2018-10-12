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
import MessageUI
import QuickLook

<<<<<<< HEAD

class CheckInfoViewController: UIViewController {
=======
class CheckInfoViewController: UIViewController  {
>>>>>>> multy_users

    @IBOutlet weak var addGuest: CustomButton!
    @IBOutlet weak var checkTableView: UITableView!
    
//    let requestResult = RequestService()
    var parentString = QrStringInfoObject() //qr-строка, по которой получали чек
    var items = [[CheckInfoObject]]()   //позиции в чеке
    var selectedItems: [CheckInfoObject] = []
    var guests = [GuestInfoObject]()    //гости, на которых разбит этот чек
    var totalSum = [Double]()
    var guestSum = 0.0
    var isFolded:[Bool] = []
<<<<<<< HEAD
=======
    var checkPlace = ""
    var checkDate = ""
>>>>>>> multy_users
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print ("viewDidLoad")
        
        self.checkTableView?.rowHeight = 60
        self.tabBarController?.tabBar.isHidden = true
        
        if !UserDefaults.standard.bool(forKey: "autoSave") {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Сохранить", style: .plain, target: self, action: #selector(showActionSheet))
        }
        
        let json = JSON.init(parseJSON: parentString.jsonString!)
        if json["document"]["receipt"]["user"].stringValue.replacingOccurrences(of: " ", with: "") != "" {
            self.checkPlace = json["document"]["receipt"]["user"].stringValue.replacingOccurrences(of: " ", with: "", options: [.anchored], range: nil )
        }
        else {
            self.checkPlace = ""
        }
        
        let string = "\(parentString.checkDate!)"
        let start = string.index(string.startIndex, offsetBy: 0)
        let end = string.index(string.startIndex, offsetBy: 16)
        let range = start..<end
        checkDate = String(string[range])

//        tableView.delegate = self
        addGuest.titleLabel?.textAlignment = .center
        addGuest.titleLabel?.text = "Выберите позиции"
        
        do {
            let realm = try Realm()
            print (parentString.qrString)
            let realmItems = realm.objects(CheckInfoObject.self).filter("%@ IN parent", parentString).sorted(byKeyPath: "sectionId")
            //создаем отдельную от базы данных копию чека и в дальнейшем работаем с ней,
            //чтобы не записывать в базу все промежуточные результаты
            var realmItemsCopy = [CheckInfoObject]()
            for item in Array(realmItems) {
                let copyItem = item.copyItem()
                realmItemsCopy.append(copyItem)
            }
            //группируем позиции в чеке по секциям (если чек ранее уже разбивался на группы)
            self.items = realmItemsCopy.reduce([[CheckInfoObject]]()) {
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
            //в список гостей этого чека добавляем имена из секций (если чек ранее уже разбивался на группы)
            //каждому гостю ставим в соответствие общую стоимость его позиций
            for item in items {
                guests.append(GuestInfoObject(name: (item.first?.sectionName)!))
                totalSum.append(item.reduce(0){$0 + round(100*$1.price*$1.totalQuantity)/100})
            }
            //каждому гостю ставим в соответствие, свернуты ли его позиции
            for _ in 0..<guests.count {
                isFolded.append(false)
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
            addGuest.titleLabel?.text = String(format: "%.2f", guestSum)
        }
        print ("foldings - \(isFolded.count)")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if guestSum != 0 {
            print ("view did disappear")
            addGuest.titleLabel?.text = String(format: "%.2f", guestSum)
        }
        if self.isMovingFromParentViewController {
            if UserDefaults.standard.bool(forKey: "autoSave") {
                self.saveTheCheck()
            }
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
        cell.isUserInteractionEnabled = true
        
        cell.sectionTitle.setTitle(guests[section].name, for: .normal)
        cell.totalSum.text = String(format: "%.2f", totalSum[section])
        cell.sectionTitle.tag = section

        cell.foldBtn.addTarget(self, action: #selector(foldBtnTap(_:)), for: .touchUpInside)
        cell.foldBtn.tag = section
        if isFolded[section] {
            cell.foldBtn.setImage(UIImage(named: "folded"), for: .normal)
        } else {
            cell.foldBtn.setImage(UIImage(named: "unfolded"), for: .normal)
        }
        return cell.contentView
    }
    
    @objc func foldBtnTap(_ sender: UIButton) {
        isFolded[sender.tag] = !isFolded[sender.tag]
        print ("@@isFolded - \(isFolded[sender.tag])")
        if isFolded[sender.tag] {
            sender.setImage(UIImage(named: "folded"), for: .normal)
        } else {
            sender.setImage(UIImage(named: "unfolded"), for: .normal)
        }
<<<<<<< HEAD
        checkTableView.reloadData()
=======
        checkTableView.beginUpdates()
        checkTableView.endUpdates()
>>>>>>> multy_users
    }
    
    //конфигурация ячейки
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemInfo", for: indexPath) as! CheckInfoCell
        cell.delegate = self
        
        cell.configure(item: items[indexPath.section][indexPath.row], section: indexPath.section)

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isFolded[indexPath.section] {
            return 0
        } else {
            return 60
        }
    }
    
    //изменение количества выбранных единиц товара
    func amountTapped(_ cell: CheckInfoCell) {
        let indexPath = self.checkTableView.indexPath(for: cell)!
        let item = items[indexPath.section][indexPath.row]
        
        //myQuantity - количество выбранных единиц товара
        let myQuantityOld = item.myQuantity
        
        //если товар не был выбран - выбираем его, выделяем ячейку
        if myQuantityOld == 0 {
            checkTableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            self.tableView(checkTableView, didSelectRowAt: indexPath)
        }
        //если товар уже выбран - добавляем количество выбранных единиц товара
        else {
            //обрабатываем тап только если товар счетный и его больше 1
            if item.isCountable && (item.totalQuantity > 1) {
                item.myQuantity = myQuantityOld % Int(item.totalQuantity) + 1
                item.myQtotalQ = "\(item.myQuantity)/\(Int(item.totalQuantity))"
                
                cell.itemAmount.text = item.myQtotalQ
                
                guestSum += Double(item.myQuantity-myQuantityOld)*item.price
                addGuest.titleLabel?.text = String(format: "%.2f", guestSum)
            }
        }
    }
    
    //высота заголовка секции
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
        
    }
    
    //выделение ячейки.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as! CheckInfoCell
        let item = items[indexPath.section][indexPath.row]
        print("choose: \(item.myQtotalQ)")
        
        
        if !item.isCountable {
            item.myQtotalQ = "\(item.totalQuantity)"
            guestSum += item.sum
        }
        else {
            //Устанавливаем количество выбранных единиц товара = 1
            item.myQuantity = 1 //<-- поменяла += на =
            guestSum += Double(item.myQuantity)*item.price
            
            if item.totalQuantity == 1 {
                item.myQtotalQ = "1"
            } else {
                item.myQtotalQ = "\(item.myQuantity)/\(Int(item.totalQuantity))"
            }
        }
        
        cell.itemAmount.text = item.myQtotalQ
        selectedItems.append(item)
        print("appended, total \(selectedItems.count)")
        
        addGuest.titleLabel?.text = String(format: "%.2f", guestSum)
        
        
    }
    
    //снятие выделения ячейки.
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let deselectedCell = tableView.cellForRow(at: indexPath) as! CheckInfoCell
        let item = items[indexPath.section][indexPath.row]
        
        //Устанавливаем количество единиц товара = totalQuantity, выбранных единиц товара = 0
        //Уменьшаем guestSum
        if(selectedItems.contains(item)){
            print("contains")
            if item.isCountable {
                guestSum -= Double(item.myQuantity)*item.price
                item.myQtotalQ = "\(Int(item.totalQuantity))"
            } else {
                guestSum -= item.sum
                item.myQtotalQ = "\(item.totalQuantity)"
            }
            
            addGuest.titleLabel?.text = String(format: "%.2f", guestSum)
            item.myQuantity = 0
            
            let index = selectedItems.index(of: item)
            selectedItems.remove(at: index!)
            deselectedCell.itemAmount.text = item.myQtotalQ
            print("removed, total  \(selectedItems.count)")
        } else {
            print("not removed, total  \(selectedItems.count)")
        }
        
        if selectedItems.isEmpty {
            addGuest.titleLabel?.text = "Выберите позиции"
        }
    }
    
    //устанавливаем стиль .delete для всех ячеек кроме первой секции
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if indexPath.section == 0 {
            return .none
        } else {
            return .delete
        }
    }
    
    //удаляем запись
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("delete")
            let item = items[indexPath.section][indexPath.row]
            item.printInfo()
            
            //при удалении позиции у гостя смотрим, есть ли эти же позиции в общем чеке
            //если в общем чеке есть этот товар, добавляем к его количеству количество из удаленной строки
            if items[0].contains(where: {$0.id == item.id}) {
                print("Check contains item")
                
                let itemInCheck = items[0].first(where: {$0 == item})
                let index = items[0].index(of: itemInCheck!)
                items[0][index!].totalQuantity += item.totalQuantity
                items[0][index!].myQuantity = 0
                items[0][index!].myQtotalQ = "\(Int(items[0][index!].totalQuantity))"
                print(items[0][index!].totalQuantity)
                
            }
            //если в общем чеке нет этого товара, вставляем в общем чеке строку с ним
            else {
                print ("Check doesn't contain item")
                
                item.sectionId = 0
                item.sectionName = "Общий чек"
                items[0].append(item)
                items[0].sort(by: {$0.id < $1.id})
                
                checkTableView.beginUpdates()
                checkTableView.insertRows(at: [IndexPath(row: items[0].count-1, section:0)], with: .none)
                checkTableView.endUpdates()
            }
            
            //удаляем строку из секции гостя и обновляем значения сумм
            items[indexPath.section].remove(at: indexPath.row)
            var itemSum = 0.0
            if item.isCountable {
                itemSum = item.totalQuantity*item.price
            } else {
                itemSum = item.sum
            }
            totalSum[indexPath.section] -= itemSum
            totalSum[0] += itemSum
            checkTableView.deleteRows(at: [indexPath], with: .left)
            
            //если в секции не осталось строк, удаляем секцию
            if items[indexPath.section].count == 0 {
                items.remove(at: indexPath.section)
                guests.remove(at: indexPath.section)
                totalSum.remove(at: indexPath.section)
                isFolded.remove(at: indexPath.section)
                
                for i in indexPath.section..<items.count {
                    for item in items[i] {
                        item.sectionId -= 1
                    }
                }
            }
            checkTableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeGuestName" {
            let controller = segue.destination as! ChangeGuestNameViewController
            if let button = sender as! UIButton? {
                print ("pressed button \(button.tag)")
                controller.sectionNo = button.tag
            }
        }
    }
}
<<<<<<< HEAD

extension CheckInfoViewController {
    
    //добавляем favouriteGuest на экран с чеком по нажатию на ячейку или кнопку +
    @IBAction func addGuestToCheck (segue: UIStoryboardSegue) {
        if segue.identifier == "addFavouriteGuestToCheck" {
            let guestViewCotroller = segue.source as! CheckGuestsViewController
//            let resultViewController = segue.destination as! ResultViewController
            
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
            //            let resultViewController = segue.destination as! ResultViewController
            
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
            newSectionItems.append(CheckInfoObject(sectionId: sectionNo, sectionName: sectionName, id: item.id, name: item.name, initialQuantity: item.initialQuantity, totalQuantity: itemQuantity, price: item.price, sum: item.sum*100))
            print("new item id: \(newSectionItems.last!.id)")
            
            //из общего чека удаляем товары, перешедшие к гостю, или уменьшаем их количество
            let index = items[0].index(of: item)
            if !item.isCountable || (item.totalQuantity == 1) {
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
            newItems.append(CheckInfoObject(sectionId: sectionNo, sectionName: sectionName, id: item.id, name: item.name, initialQuantity: item.initialQuantity, totalQuantity: itemQuantity, price: item.price, sum: item.sum*100))
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
    }
    
    //сохранение чека
    @objc func saveTheCheck() {
        //создаем новый массив и копируем туда наш чек
        var itemsToRealm: [CheckInfoObject] = []
        
        for section in items {
            for item in section {
                let copyItem = item.copyItem()
                itemsToRealm.append(copyItem)
            }
        }
        //удаляем старый чек, записываем в realm новый массив
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

extension CheckInfoViewController {
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
                } catch {
                    print (error)
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
            } catch {
                print (error)
            }
            checkTableView.reloadData()
        }
    }
}
=======
>>>>>>> multy_users
