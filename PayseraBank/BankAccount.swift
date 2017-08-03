//
//  BankAccoud.swift
//  PayseraDemo
//
//  Created by Egidijus Ambrazas on 01/08/2017.
//  Copyright © 2017 Egidijus Ambrazas. All rights reserved.
//

import Foundation

enum Currency:String {
    case EUR = "EUR"
    case USD = "USD"
    case JPY = "JPY"
    
    static let allValues = [EUR, USD, JPY]
    
    var sign:String {
        switch self {
        case .EUR:
            return "€"
        case .USD:
            return "$"
        case .JPY:
            return "¥"
        }
    }
}

class CurrencyAccount {
    let name: String
    let currency: Currency
    var deposit: Float
    
    init(name: String, currency: Currency) {
        self.name = name
        self.currency = currency
        self.deposit = 1000
    }
}

struct Operation {
    let fromCurrency:Currency
    let toCurrency:Currency
    let fromAmount:Float
    let toAmount:Float
    let cost:Float
}

class BankAccount {
    var operationsMade: Int = 0
    
    // All user accounts
    var accounts = [CurrencyAccount]()
    
    // All successfull operations
    var history = [Operation]()
    
    weak var delegate:ExchangeDelegate?
    
    // Calculating commission value based on how many operations are made
    var cost:Float {
        get {
            switch operationsMade {
            case 0...4:
                return 0.000
            default:
                return 0.007
            }
        }
    }
    
    // Making singleton
    static let shared: BankAccount = {
        let instance = BankAccount()
        
        for c in Currency.allValues {
            let currencyAccount = CurrencyAccount(name: c.rawValue, currency: c)
            instance.accounts.append(currencyAccount)
        }
        
        return instance
    }()
    
    
    func convertMoney(fromCurrency: CurrencyAccount, toCurrency: CurrencyAccount, amount: Float) {
        
        var amountForConvertion = amount
        var commission = amountForConvertion * cost
        
        let total = amountForConvertion + commission
        
        // If amount and commission is bigger  than deposit, then biggest available amountForConvertion value is calculated
        if  total > fromCurrency.deposit {
            amountForConvertion = fromCurrency.deposit / (1 + cost)
            commission = fromCurrency.deposit - amountForConvertion
        }
        
        let url = URL(string: "http://api.evp.lt/currency/commercial/exchange/\(amountForConvertion)-\(fromCurrency.currency.rawValue)/\(toCurrency.currency.rawValue)/latest")!
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard (error == nil) else {
                print("There was an error with your request: \(String(describing: error))")
                self.sendResults(operation: nil)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!")
                self.sendResults(operation: nil)
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                self.sendResults(operation: nil)
                return
            }
            
            // parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                self.sendResults(operation: nil)
                return
            }
            
            guard let convertedAmount = Float(parsedResult["amount"] as! String) else {
                print("Can't fint 'amount' key ")
                self.sendResults(operation: nil)
                return
            }
            
            // Only if convertedAmount is more than zero, operation is marked as successfull
            // Otherwise -> fail. 
            if convertedAmount > 0 {
                fromCurrency.deposit = fromCurrency.deposit - amountForConvertion - commission
                toCurrency.deposit += convertedAmount
                self.operationsMade += 1
                
                let operation = Operation(fromCurrency: fromCurrency.currency, toCurrency: toCurrency.currency, fromAmount: amountForConvertion, toAmount: convertedAmount, cost: commission)
                
                self.history.append(operation)
                self.sendResults(operation: operation)
            } else {
                self.sendResults(operation: nil)
            }

        }
        task.resume()
 
    }
    
    // sends results to Main ui thread
    func sendResults(operation: Operation?) {
        DispatchQueue.main.async {
            self.delegate?.exchageResults(operation: operation)
        }
    }
    
    
}
