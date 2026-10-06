//
//  StockTests.swift
//  multibankgroup-stocks
//
//  Created by Zois Avgerinos on 6/10/26.
//

import Testing
@testable import multibankgroup_stocks

// MARK: - StockTests -

@Suite("Stock")
struct StockTests {

    @Test("apply updates price, previousPrice, and derived change")
    func applyEchoedUpdate() {
        var stock = Stock(
            symbol: "AAPL",
            name: "Apple",
            description: "Test",
            price: 100,
            previousPrice: 100
        )

        stock.apply(PriceUpdate(symbol: "AAPL", price: 110))

        #expect(stock.price == 110)
        #expect(stock.previousPrice == 100)
        #expect(stock.priceChange == 10)
        #expect(stock.changePercent == 10)
        #expect(stock.isPositive)
    }

    @Test("apply ignores a different symbol")
    func applyIgnoresOtherSymbol() {
        var stock = Stock(
            symbol: "AAPL",
            name: "Apple",
            description: "Test",
            price: 100,
            previousPrice: 100
        )

        stock.apply(PriceUpdate(symbol: "MSFT", price: 200))

        #expect(stock.price == 100)
        #expect(stock.previousPrice == 100)
    }

    @Test("changePercent is zero when previousPrice is zero")
    func changePercentGuardsDivideByZero() {
        let stock = Stock(
            symbol: "X",
            name: "X",
            description: "",
            price: 5,
            previousPrice: 0
        )

        #expect(stock.changePercent == 0)
    }

    @Test("catalog seeds 25 symbols")
    func catalogHasTwentyFiveSymbols() {
        #expect(StockCatalog.stocks.count == 25)
        #expect(Set(StockCatalog.stocks.map(\.symbol)).count == 25)
    }
}
