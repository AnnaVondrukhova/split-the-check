//
//  YearMonth.swift
//  SplitTheCheck
//
//  Created by Anya on 25/09/2018.
//  Copyright © 2018 Anna Zhulidova. All rights reserved.
//

import Foundation

struct YearMonth: Comparable, Hashable {
    let year: Int
    let month: Int
    
    init(year: Int, month: Int) {
        self.year = year
        self.month = month
    }
    
    init(date: Date) {
        let comps = Calendar.current.dateComponents([.year, .month], from: date)
        self.year = comps.year!
        self.month = comps.month!
    }
    
    var hashValue: Int {
        return year * 12 + month
    }
    
    static func == (lhs: YearMonth, rhs: YearMonth) -> Bool {
        return lhs.year == rhs.year && lhs.month == rhs.month
    }
    
    static func < (lhs: YearMonth, rhs: YearMonth) -> Bool {
        if lhs.year != rhs.year {
            return lhs.year < rhs.year
        } else {
            return lhs.month < rhs.month
        }
    }
}
