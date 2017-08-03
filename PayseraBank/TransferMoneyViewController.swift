//
//  TransferMoneyViewController.swift
//  PayseraBank
//
//  Created by Egidijus Ambrazas on 01/08/2017.
//  Copyright © 2017 Egidijus Ambrazas. All rights reserved.
//

import UIKit

protocol ExchangeDelegate: class {
    func exchageResults(operation:Operation?)
}

class TransferMoneyViewController: UIViewController{

    @IBOutlet weak var fromAccount: UIPickerView!
    @IBOutlet weak var toAccount: UIPickerView!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var actionButton: UIButton!
    
    
    @IBAction func convertAction(_ sender: Any) {
        print(BankAccount.shared.accounts[fromAccount.selectedRow(inComponent: 0)].currency)
        
        guard let amount = Float(amountTextField.text!) else {
            print("Wrong number")
            return
        }
        
        BankAccount.shared.convertMoney(
            fromCurrency: BankAccount.shared.accounts[fromAccount.selectedRow(inComponent: 0)],
            toCurrency: BankAccount.shared.accounts[toAccount.selectedRow(inComponent: 0)],
            amount: amount)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fromAccount.delegate = self
        fromAccount.dataSource = self
        
        toAccount.delegate = self
        toAccount.dataSource = self
        
        amountTextField.delegate = self

        
        BankAccount.shared.delegate = self
        
        actionButton.isEnabled = false;
    }
    
    func validateForm() {
        print("validateForm")
        
        var valid = true
        if fromAccount.selectedRow(inComponent: 0) == toAccount.selectedRow(inComponent: 0) {
            valid = false
        }
        
        if let amount = Float(amountTextField.text!) {
            print("Amount: \(amount)")
            if amount <= 0 {
                valid = false
            }
        } else {
            valid = false
        }
        
        actionButton.isEnabled = valid
    }
}

extension TransferMoneyViewController: ExchangeDelegate {
    func exchageResults(operation: Operation?) {
        
        fromAccount.reloadAllComponents()
        toAccount.reloadAllComponents()
        
        if let operation = operation {
            
            amountTextField.text = ""
            
            let alert = UIAlertController(title: "Pervedimas pavyko", message: "Jūs konvertavote \(operation.fromAmount) \(operation.fromCurrency) į \(operation.toAmount) \(operation.toCurrency). Komisinis mokestis - \(operation.cost) \(operation.fromCurrency).", preferredStyle: .alert)
            
            let closeAction = UIAlertAction(title: "Uždaryti", style: .default, handler: nil)
            alert.addAction(closeAction)
            self.present(alert, animated: true, completion: nil)
            
            
            
        } else {
            let alert = UIAlertController(title: "Klaida", message: "Pervedimas nepavyko", preferredStyle: .alert)
            
            let closeAction = UIAlertAction(title: "Uždaryti", style: .default, handler: nil)
            alert.addAction(closeAction)
            self.present(alert, animated: true, completion: nil)
        }
         
    }
}


extension TransferMoneyViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        validateForm()
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(BankAccount.shared.accounts[row].currency.rawValue) (\(BankAccount.shared.accounts[row].deposit) \(BankAccount.shared.accounts[row].currency.sign))"
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return BankAccount.shared.accounts.count
    }
}


extension TransferMoneyViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        amountTextField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        validateForm()
    }
}
