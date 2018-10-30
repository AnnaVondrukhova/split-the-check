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


class CheckInfoViewController: UIViewController {

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
    var checkPlace = ""
    var checkDate = ""
    var checkHeader = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print ("viewDidLoad")
        NSLog("CheckInfoVC did load")
        
        self.checkTableView?.rowHeight = 60
        self.tabBarController?.tabBar.isHidden = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "more"), style: .plain, target: self, action: #selector(showActionSheet))
        
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
        
        if checkPlace != "" {
            checkHeader = checkPlace + "_" + checkDate
        } else {
            checkHeader = "Чек_" + checkDate
        }

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
            print("items grouped")
            NSLog("group items: success")

        } catch {
            print (error)
            NSLog ("group items: error" + error.localizedDescription)
        }
        print ("total sum")
        self.checkTableView?.reloadData()
        print ("Items : \(items)")
    }

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
        //если включено автосохранение, сохраняем чек, покидая контроллер
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

//extension для работы с таблицей: выбор строк, выбор количества товара, удаление строк из секции
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
    
    //обработка нажатия на кнопку foldBtn
    @objc func foldBtnTap(_ sender: UIButton) {
        isFolded[sender.tag] = !isFolded[sender.tag]
        print ("@@isFolded - \(isFolded[sender.tag])")
        if isFolded[sender.tag] {
            sender.setImage(UIImage(named: "folded"), for: .normal)
        } else {
            sender.setImage(UIImage(named: "unfolded"), for: .normal)
        }
        checkTableView.beginUpdates()
        checkTableView.endUpdates()
    }

    
    //конфигурация ячейки
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemInfo", for: indexPath) as! CheckInfoCell
        let item = items[indexPath.section][indexPath.row]
        cell.delegate = self
        
        item.isSelected = cell.isSelected
        cell.configure(item: items[indexPath.section][indexPath.row], section: indexPath.section)

        return cell
    }
    
    //меняем высоту ячейки в зависимости от isFolded
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
                NSLog("added item amount")
            }
        }
        print ("item.myQuantity = \(item.myQuantity)")
    }
    
    //высота заголовка секции. Если в секции нет товаров, высота заголовка = 0
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if items[section].isEmpty {
            return 0
        } else {
            return 40
        }
    }
    
    //выделение ячейки.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as! CheckInfoCell
        let item = items[indexPath.section][indexPath.row]
        item.isSelected = true
        print("choose: \(item.myQtotalQ)")
        NSLog("selected row at section \(indexPath.section), row \(indexPath.row)")
        
        
        if !item.isCountable {
            item.myQtotalQ = "\(item.totalQuantity)"
            item.myQuantity  = 1
            guestSum += item.sum
        }
        else {
            //Устанавливаем количество выбранных единиц товара = 1
            item.myQuantity = 1
            guestSum += Double(item.myQuantity)*item.price
            
            if item.totalQuantity == 1 {
                item.myQtotalQ = "1"
            } else {
                item.myQtotalQ = "\(item.myQuantity)/\(Int(item.totalQuantity))"
            }
        }
        
        cell.configure(item: item, section: indexPath.section)
        selectedItems.append(item)
        print("appended, total \(selectedItems.count)")
        
        addGuest.titleLabel?.text = String(format: "%.2f", guestSum)
    }
    
    //снятие выделения ячейки.
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let deselectedCell = tableView.cellForRow(at: indexPath) as! CheckInfoCell
        let item = items[indexPath.section][indexPath.row]
        item.isSelected = false
        NSLog("deselected row at section \(indexPath.section), row \(indexPath.row)")
        
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
            deselectedCell.configure(item: item, section: indexPath.section)
            print("removed, total  \(selectedItems.count)")
            NSLog("selectedItems contains item: removed")
        } else {
            print("not removed, total  \(selectedItems.count)")
            NSLog("selectedItems doesn't contain item: not removed")
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
                NSLog("Remove item from section: check contains item")
            }
            //если в общем чеке нет этого товара, вставляем в общем чеке строку с ним
            else {
                print ("Check doesn't contain item")
                
                item.sectionId = 0
                item.sectionName = "Не распределено"
                items[0].append(item)
                items[0].sort(by: {$0.id < $1.id})
                
                checkTableView.beginUpdates()
                checkTableView.insertRows(at: [IndexPath(row: items[0].count-1, section:0)], with: .none)
                checkTableView.endUpdates()
                NSLog("Remove item from section: check doesn't contain item")
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
                NSLog("removing section")
            }
            checkTableView.reloadData()
        }
    }
}
