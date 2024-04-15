//
//  StoreTests.swift
//  StoreTests
//
//  Created by Ted Neward on 2/29/24.
//

import XCTest

final class StoreTests: XCTestCase {

    var register = Register()

    override func setUpWithError() throws {
        register = Register()
    }

    override func tearDownWithError() throws { }

    func testBaseline() throws {
        XCTAssertEqual("0.1", Store().version)
        XCTAssertEqual("Hello world", Store().helloWorld())
    }
    
    func testOneItem() {
        register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))
        XCTAssertEqual(199, register.subtotal())
        
        let receipt = register.total()
        XCTAssertEqual(199, receipt.total())

        let expectedReceipt = """
Receipt:
Beans (8oz Can): $1.99
------------------
TOTAL: $1.99
"""
        XCTAssertEqual(expectedReceipt, receipt.output())
    }
    
    func testThreeSameItems() {
        register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))
        register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))
        register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))
        XCTAssertEqual(199 * 3, register.subtotal())
    }
    
    func testThreeDifferentItems() {
        register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))
        XCTAssertEqual(199, register.subtotal())
        register.scan(Item(name: "Pencil", priceEach: 99))
        XCTAssertEqual(298, register.subtotal())
        register.scan(Item(name: "Granols Bars (Box, 8ct)", priceEach: 499))
        XCTAssertEqual(797, register.subtotal())
        
        let receipt = register.total()
        XCTAssertEqual(797, receipt.total())

        let expectedReceipt = """
Receipt:
Beans (8oz Can): $1.99
Pencil: $0.99
Granols Bars (Box, 8ct): $4.99
------------------
TOTAL: $7.97
"""
        XCTAssertEqual(expectedReceipt, receipt.output())
    }
    
    // Added tests
    // Test adding a single Item to the Register and displays its subtotal (which should be the single Item's price)
    func testAddingSingleItemSubtotal() throws {
        let pencil = Item(name: "Pencil", priceEach: 99)
        register.scan(pencil)
        let expectedSubtotal = pencil.price()
        XCTAssertEqual(expectedSubtotal, register.subtotal())
    }
    
    // Test 2-for-1 Pricing
    func testTwoForOnePricing() {
        let pricingScheme = TwoForOnePricing(itemName: "Beans (8oz Can)", itemPrice: 199)
        let register = Register(pricingScheme: pricingScheme)
        
        register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))
        register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))
        register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))
        XCTAssertEqual(398, register.subtotal())
    }
    
    // Test 2-for-1 Pricing
    func testMultipleTwoForOnePricing() {
        let pricingScheme = TwoForOnePricing(itemName: "Beans (8oz Can)", itemPrice: 199)
        let register = Register(pricingScheme: pricingScheme)
        for _ in 1...6 {
            register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))
        }

        let expectedSubtotal = 4 * 199
        XCTAssertEqual(expectedSubtotal, register.subtotal())

        let receipt = register.total()
        let expectedReceipt = """
        Receipt:
        Beans (8oz Can): $1.99
        Beans (8oz Can): $1.99
        Beans (8oz Can): $1.99
        Beans (8oz Can): $1.99
        Beans (8oz Can): $1.99
        Beans (8oz Can): $1.99
        ------------------
        TOTAL: $7.96
        """
        XCTAssertEqual(expectedReceipt, receipt.output())
    }
    
    // Test Coupon Discount
    func testCouponDiscount() {
        let coupon = Coupon(itemName: "Beans (8oz Can)")
        let register = Register(coupon: coupon)
        
        register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))
        register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))
        
        let expectedSubtotal = 199 + Int(199 * 0.85) 
        // One full price, one with 15% discount
        XCTAssertEqual(register.subtotal(), expectedSubtotal)
    }
    
    // // Test Coupon Discount
    func testMixedItemsSingleCoupon() {
        let coupon = Coupon(itemName: "Beans (8oz Can)")
        let register = Register(coupon: coupon)
        
        register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))
        register.scan(Item(name: "Pencil", priceEach: 50))
        register.scan(Item(name: "Granola Bars (Box, 8ct)", priceEach: 300))
        register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))

        let expectedSubtotal = Int(199 * 0.85) + 50 + 300 + 199
        // One can with discount, others full price
        XCTAssertEqual(register.subtotal(), expectedSubtotal)
    }


}
