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

protocol PricingScheme {
    func calculatePrice(for items: [Item]) -> Int
}

class TwoForOnePricing: PricingScheme {
    var eligibleItemName: String
    var itemPrice: Int

    init(itemName: String, itemPrice: Int) {
        self.eligibleItemName = itemName
        self.itemPrice = itemPrice
    }

    func calculatePrice(for items: [Item]) -> Int {
        let eligibleItems = items.filter { $0.name == eligibleItemName }
        let count = eligibleItems.count
        let groupsOfThree = count / 3
        return (groupsOfThree * 2 + (count - groupsOfThree * 3)) * itemPrice
    }
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
    private var items: [Item] = []
    var pricingScheme: PricingScheme?
    var coupon: Coupon?

    init(pricingScheme: PricingScheme? = nil, coupon: Coupon? = nil) {
        self.pricingScheme = pricingScheme
        self.coupon = coupon
    }

    func add(item: Item) {
        items.append(item)
    }

    func itemsList() -> [SKU] {
        return items
    }

    func total() -> Int {
        if let scheme = pricingScheme {
            return scheme.calculatePrice(for: items)
        }

        var total = 0
        var couponApplied = false
        for item in items {
            if !couponApplied, let coupon = coupon, item.name == coupon.itemName {
                total += coupon.applyCoupon(to: item.price())
                couponApplied = true
            } else {
                total += item.price()
            }
        }
        return total
    }

    func output() -> String {
        var output = "Receipt:\n"
        for item in items {
            output += "\(item.name): $\(item.price() / 100).\(String(format: "%02d", item.price() % 100))\n"
        }
        output += "------------------\n"
        output += "TOTAL: $\(total() / 100).\(String(format: "%02d", total() % 100))"
        return output
    }
}

class Register {
    private var receipt: Receipt

    init(pricingScheme: PricingScheme? = nil, coupon: Coupon? = nil) {
        self.receipt = Receipt(pricingScheme: pricingScheme, coupon: coupon)
    }

    func scan(_ item: Item) {
        receipt.add(item: item)
    }

    func subtotal() -> Int {
        return receipt.total()
    }

    func total() -> Receipt {
        let finalReceipt = receipt
        receipt = Receipt(pricingScheme: receipt.pricingScheme, coupon: receipt.coupon) // Carry over the pricing scheme and coupon
        return finalReceipt
    }
}


class Coupon {
    var itemName: String
    var discountRate: Double

    init(itemName: String, discountRate: Double = 0.15) {
        self.itemName = itemName
        self.discountRate = discountRate
    }

    func applyCoupon(to itemPrice: Int) -> Int {
        return Int(Double(itemPrice) * (1.0 - discountRate))
    }
}


class Store {
    let version = "0.1"
    func helloWorld() -> String {
        return "Hello world"
    }
}

