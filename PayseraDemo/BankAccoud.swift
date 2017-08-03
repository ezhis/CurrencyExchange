//
//  BankAccoud.swift
//  PayseraDemo
//
//  Created by Egidijus Ambrazas on 01/08/2017.
//  Copyright © 2017 Egidijus Ambrazas. All rights reserved.
//

import Foundation

enum Currency:string {
    case EUR = "EUR"
    case USD = "USD"
    case JPY = "JPY"
}

struct CurrencyAccount {
    let name: string
    let currency: Currency
    var deposit: float
    var operationsMade: int
    
    init(name: string, currency: Currency) {
        self.name = name
        self.currency = currency
        self.deposit = 1000
        self.operationsMade = 0
    }
}

class BankAccoud {
    
}
