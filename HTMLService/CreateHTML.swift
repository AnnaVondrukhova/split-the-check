//
//  CreateHTML.swift
//  SplitTheCheck
//
//  Created by Anya on 13.07.2020.
//  Copyright © 2020 Anna Zhulidova. All rights reserved.
//

import Foundation

class CreateHTML {
    //делаем из чека html и сохраняем в файл
    static func create(items: [[CheckInfoObject]], totalSum: [Double], guests: [GuestInfoObject], checkPlace: String, checkDate: String) -> String {
            let pathToCheckTemplate = Bundle.main.path(forResource: "check", ofType: "html")
            let pathToCheckHeaderTemplate = Bundle.main.path(forResource: "checkHeader", ofType: "html")
            let pathToSectionHeaderTemplate = Bundle.main.path(forResource: "sectionHeader", ofType: "html")
            let pathToSectionRowTemplate = Bundle.main.path(forResource: "sectionRow", ofType: "html")
            
            do {
                var checkHTML = try String(contentsOfFile: pathToCheckTemplate!)
                
                var checkBody = ""
                var checkHeader = ""
                
                //создаем секции чека
                var startIndex = 0
                if totalSum[0] == 0 {
                    startIndex = 1
                }
                
                for i in startIndex..<items.count {
                    var sectionBody = ""
                    var sectionHeader = try String(contentsOfFile: pathToSectionHeaderTemplate!)
                    var checkHeaderRow = try String(contentsOfFile: pathToCheckHeaderTemplate!)
                    
                    sectionHeader = sectionHeader.replacingOccurrences(of: "#SECTION_NAME#", with: guests[i].name)
                    sectionHeader = sectionHeader.replacingOccurrences(of: "#SECTION_SUM#", with: String(format: "%.2f", totalSum[i]))
                    sectionBody.append(sectionHeader)
                    
                    //создаем строки в заголовке чека
                    checkHeaderRow = checkHeaderRow.replacingOccurrences(of: "#GUEST_NAME#", with: guests[i].name)
                    checkHeaderRow = checkHeaderRow.replacingOccurrences(of: "#GUEST_SUM#", with: String(format: "%.2f", totalSum[i]))
                    checkHeader.append(checkHeaderRow)
                    
                    //создаем строки секции чека
                    for j in 0..<items[i].count {
                        var itemBody = try String(contentsOfFile: pathToSectionRowTemplate!)
                        
                        itemBody = itemBody.replacingOccurrences(of: "#ITEM_NAME#", with: items[i][j].name)
                        itemBody =  itemBody.replacingOccurrences(of: "#ITEM_PRICE#", with: "\(items[i][j].price)")
                        itemBody =  itemBody.replacingOccurrences(of: "#ITEM_AMOUNT#", with: items[i][j].myQtotalQ)
                        
                        var itemSum = ""
                        if items[i][j].isCountable {
                            itemSum = String(format: "%.2f", round(100*items[i][j].totalQuantity*items[i][j].price)/100)
                        } else {
                            itemSum = String(items[i][j].sum)
                        }
                        itemBody = itemBody.replacingOccurrences(of: "#ITEM_SUM#", with: itemSum)
                        
                        sectionBody.append(itemBody)
                    }
                    
                    checkBody.append(sectionBody)
                }
                checkHTML = checkHTML.replacingOccurrences(of: "#CHECK_PLACE#", with: checkPlace)
                checkHTML = checkHTML.replacingOccurrences(of: "#CHECK_DATE#", with: checkDate)
                checkHTML = checkHTML.replacingOccurrences(of: "#CHECK_HEADER#", with: checkHeader)
                checkHTML = checkHTML.replacingOccurrences(of: "#CHECK_BODY#", with: checkBody)
    //            createMessageBody(text: checkHTML)
                print ("html created")
                NSLog("HTML created")
                return checkHTML
                
            } catch {
                print("Unable to open and use HTML template files.")
                NSLog("Unable to open and use HTML template files.")
                return ""
            }
        }
        
}
