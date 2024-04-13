//
//  main.swift
//  Store
//
//  Created by Ted Neward on 2/29/24.
//

import Foundation

protocol SKU {
    var name: String { get }
    func price() -> Int
}

class Item: SKU {
    var name: String
    private var itemPrice: Int

    init(name: String, priceEach: Int) {
        self.name = name
        self.itemPrice = priceEach
    }

    func price() -> Int {
        return itemPrice
    }
}

class Receipt {
    private var items: [SKU] = []

    func add(item: SKU) {
        items.append(item)
    }

    func itemsList() -> [SKU] {
        return items
    }

    func total() -> Int {
        return items.reduce(0) { $0 + $1.price() }
    }

    func output() -> String {
        var output = "Receipt:\n"
        for item in items {
            output += "\(item.name): $\(item.price() / 100).\(String(format: "%02d", item.price() % 100))\n"
        }
        output += "------------------\n"
        output += "TOTAL: $\(total() / 100).\(String(format: "%02d", total() % 100))"
        return output // No newline at the end
    }
}

class Register {
    private var receipt = Receipt()

    func scan(_ item: SKU) {
        receipt.add(item: item)
    }

    func subtotal() -> Int {
        return receipt.itemsList().reduce(0, { $0 + $1.price() })
    }

    func total() -> Receipt {
        let finalReceipt = receipt
        receipt = Receipt() // Reset for a new transaction
        return finalReceipt
    }
}

class Store {
    let version = "0.1"
    func helloWorld() -> String {
        return "Hello world"
    }
}

