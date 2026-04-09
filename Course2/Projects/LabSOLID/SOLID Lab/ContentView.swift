//
//  ContentView.swift
//  SOLID Lab
//
//  Created by Tyson Pitcher on 3/18/26.
//

import SwiftUI
import Foundation
import Observation

// Single Responsibility Principle
protocol AccountHolderDataStore {
    func getAllAccountHolders(_ accountHolder: AccountHolder) -> [AccountHolder]
    func saveAccountHolder(_ accountHolder: AccountHolder)
    func fetchAccountHolder(withId id: String) -> AccountHolder?
}
class SwiftDataStore: AccountHolderDataStore {
    func getAllAccountHolders(_ accountHolder: AccountHolder) -> [AccountHolder] {
        // Fetch all AccountHolders from Swift Data
        fatalError()
    }

    func saveAccountHolder(_ accountHolder: AccountHolder) {
        // Save AccountHolder into Swift Data
    }
    func fetchAccountHolder(withId id: String) -> AccountHolder? {
        fatalError()
        // fetch an account holder by ID from SwiftData
    }
}
class FileSystemDataStore: AccountHolderDataStore {
    let filePath: String = "accountHolders.json"
    var accountHolders: [AccountHolder]
    
    init() {
        // Fetch all accountHolders from filePath. Default to []
        fatalError()
    }
    
    func getAllAccountHolders(_ accountHolder: AccountHolder) -> [AccountHolder] {
        return accountHolders
    }

    func saveAccountHolder(_ accountHolder: AccountHolder) {
        // Update filepath with new information
        accountHolders.append(accountHolder)
        // Convert `accountHolders` to Data and save to filePath
    }
    func fetchAccountHolder(withId id: String) -> AccountHolder? {
//        accountHolders.first(where: { $0.id == id })
        fatalError()
    }
}
class AccountHolder {
    var name: String
    var accountNumber: Int
    init(name: String, accountNumber: Int) {
        self.name = name
        self.accountNumber = accountNumber
    }
}
class ViewModel {
    let dataStore: AccountHolderDataStore
    init(dataStore: AccountHolderDataStore) {
        self.dataStore = dataStore
    }
    
}

let viewModel = ViewModel(dataStore: SwiftDataStore())
let viewModel2 = ViewModel(dataStore: FileSystemDataStore())



// Open/Closed Principle
class Amount {
    var amount: Double
    var taxPercent: Double?
    var total: Double {
        amount + (amount * (taxPercent ?? 0))
    }
    init(amount: Double, taxPercent: Double? = nil) {
        self.amount = amount
    }
}

class FeeableAmount: Amount {
    var nonTaxableFee: Double?
    
    init(amount: Double, taxPercent: Double? = nil, nonTaxableFee: Double? = nil) {
        self.nonTaxableFee = nonTaxableFee
        super.init(amount: amount, taxPercent: taxPercent)
    }
    
    // Breaks Liscov Substitution
//    init(nonTaxableFee: Double? = nil) {
//        self.nonTaxableFee = nonTaxableFee
//        super.init(amount: 0, taxPercent: 0)
//    }
//    
    
    override var total: Double {
        let taxableTotal = super.total // Doesn't break logic of superclass
        return taxableTotal + (nonTaxableFee ?? 0)
    }
}

protocol DepositProcessor {
    func processDeposit(_ amount: Amount)
}
class AppDeposit: DepositProcessor {
    func processDeposit(_ amount: Amount) {
    }
}
class BankDeposit: DepositProcessor {
    private let verifyID: Bool
    
    init(verifyID: Bool) {
        self.verifyID = verifyID
    }
    func processDeposit(_ amount: Amount) {
    }
}

// Liskov Substitution Principle
class HasLoan: AccountHolder {
    var loanBalance: Double = 0
    init(loanBalance: Double) {
        self.loanBalance = loanBalance
        super.init(name: "", accountNumber: 0)
    }
}

// Interface Segregation Principle
protocol Marketable {
    func sendMarketingEmail() -> [AccountHolder]
}

// Dependency Inversion
protocol Message {
    func welcomeMessage()
    func messageText()
}
//protocol Message {
//    func messageText()
//}
//protocol WelcomableMessage: Message {
//    func welcomeMessage()
//}

class SavingsAccountMesssage: Message {
    func welcomeMessage() {
        print("Thank you for opening a savings account with us!")
    }
    func messageText() {
        print("Click on the 'Saving Account' button to check your balance.")
    }
}
class CheckingAccountMessage: Message {
    func welcomeMessage() {
        print("Thank you for opening a checking account with us!")
    }
    func messageText() {
        print("Click on the 'Checking Account' button to check your balance.")
    }
}
class DetailViewMessage: Message {
    // Breaks Interface Segregation Principle
    func welcomeMessage() {
        // Don't do anything
    }
    
    func messageText() {
        print("Click on the 'Checking Account' button to check your balance.")
    }
}



class AccountViewModel {
    let messaging: Message
    init(messaging: Message) {
        self.messaging = messaging
    }
}

// SavingsAccount Button would create this ViewModel
let vm = AccountViewModel(messaging: SavingsAccountMesssage())

// CheckingAccount Button would create this ViewModel
let vm2 = AccountViewModel(messaging: CheckingAccountMessage())

