import XCTest

@testable import TBDApp

final class ModelTests: XCTestCase {
    func testItemInitialization() {
        let item = Item(
            title: "Test Item",
            purchasePrice: 10.0,
            quantity: 5,
            status: .draft
        )

        XCTAssertEqual(item.title, "Test Item")
        XCTAssertEqual(item.purchasePrice, 10.0)
        XCTAssertEqual(item.quantity, 5)
        XCTAssertEqual(item.status, .draft)
        XCTAssertNotNil(item.id)
    }

    func testSaleInitialization() {
        let itemId = UUID()
        let sale = Sale(
            itemId: itemId,
            soldPrice: 20.0,
            platform: "eBay",
            fees: 2.0,
            dateSold: Date()
        )

        XCTAssertEqual(sale.itemId, itemId)
        XCTAssertEqual(sale.soldPrice, 20.0)
        XCTAssertEqual(sale.platform, "eBay")
        XCTAssertEqual(sale.fees, 2.0)
    }
}
