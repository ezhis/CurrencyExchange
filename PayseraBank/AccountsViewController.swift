//
//  ViewController.swift
//  PayseraBank
//
//  Created by Egidijus Ambrazas on 01/08/2017.
//  Copyright © 2017 Egidijus Ambrazas. All rights reserved.
//

import UIKit

class AccountsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let bankAccount = BankAccount.shared
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showHistory" {
            let account = sender as! CurrencyAccount
            
            let ovc = segue.destination as! OperationsViewController
            ovc.history = BankAccount.shared.history.filter { $0.fromCurrency == account.currency || $0.toCurrency == account.currency}
            ovc.currency = account.currency
        }
    }
}


extension AccountsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bankAccount.accounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "currencyAccount")!
        
        let curencyAccount = bankAccount.accounts[indexPath.row]
        
        cell.textLabel?.text = "\(curencyAccount.currency)"
        cell.detailTextLabel?.text = "\(curencyAccount.deposit) \(curencyAccount.currency.sign)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let account = BankAccount.shared.accounts[indexPath.row]
        performSegue(withIdentifier: "showHistory", sender: account)
        
    }
}

