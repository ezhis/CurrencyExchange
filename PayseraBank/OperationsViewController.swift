//
//  OperationsViewController.swift
//  PayseraBank
//
//  Created by Egidijus Ambrazas on 02/08/2017.
//  Copyright © 2017 Egidijus Ambrazas. All rights reserved.
//

import UIKit

class OperationsViewController: UIViewController {

    var history: [Operation]?
    var currency: Currency?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = "Istorija \(currency!)"
    }

}

extension OperationsViewController:  UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = history?.count ?? 0
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell")!
        
        // Cheking if it is expense or income. Income value will be green, expense value - red
        // Also if it is expense, adding commission value in subtitle
        if history?[indexPath.row].fromCurrency == currency{
            cell.textLabel?.text = "-\(history?[indexPath.row].fromAmount ?? 0) \(currency!.sign)"
            cell.textLabel?.textColor = .red
            
            let details = "Komisinis: \(history?[indexPath.row].cost ?? 0) \(currency!.sign)"
            
            cell.detailTextLabel?.text = details
            cell.detailTextLabel?.textColor = .darkGray
        } else {
            cell.textLabel?.text = "+\(history?[indexPath.row].toAmount ?? 0) \(currency!.sign) "
            cell.textLabel?.textColor = .green
            cell.detailTextLabel?.text = ""
        }
        
        return cell
    }
}
