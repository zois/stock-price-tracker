//
//  SymbolDetailViewModelTests.swift
//  multibankgroup-stocks
//
//  Created by Zois Avgerinos on 6/10/26.
//

import Testing
@testable import multibankgroup_stocks

// MARK: - SymbolDetailViewModelTests -

@Suite("SymbolDetailViewModel")
@MainActor
struct SymbolDetailViewModelTests {

    @Test("consume picks the matching symbol")
    func consumeSelectsSymbol() {
        let feed = FakePriceFeed(stocks: [])
        let vm = SymbolDetailViewModel(symbol: "BBB", feed: feed)

        vm.consume(
            .stocks([
                Stock(symbol: "AAA", name: "A", description: "a", price: 10, previousPrice: 10),
                Stock(symbol: "BBB", name: "B", description: "b", price: 20, previousPrice: 20),
            ])
        )

        #expect(vm.stock?.symbol == "BBB")
        #expect(vm.stock?.price == 20)
        #expect(vm.stock?.description == "b")
    }

    @Test("consume updates price for the same symbol")
    func consumeUpdatesPrice() {
        let feed = FakePriceFeed(stocks: [])
        let vm = SymbolDetailViewModel(symbol: "BBB", feed: feed)

        vm.consume(
            .stocks([
                Stock(symbol: "BBB", name: "B", description: "b", price: 20, previousPrice: 20),
            ])
        )
        vm.consume(
            .stocks([
                Stock(symbol: "BBB", name: "B", description: "b", price: 25, previousPrice: 20),
            ])
        )

        #expect(vm.stock?.price == 25)
        #expect(vm.stock?.changePercent == 25)
    }

    @Test("consume clears stock when symbol is missing")
    func consumeMissingSymbol() {
        let feed = FakePriceFeed(stocks: [])
        let vm = SymbolDetailViewModel(symbol: "BBB", feed: feed)

        vm.consume(
            .stocks([
                Stock(symbol: "BBB", name: "B", description: "b", price: 20, previousPrice: 20),
            ])
        )
        vm.consume(
            .stocks([
                Stock(symbol: "AAA", name: "A", description: "a", price: 10, previousPrice: 10),
            ])
        )

        #expect(vm.stock == nil)
    }

    @Test("connection events are ignored")
    func ignoresConnection() {
        let feed = FakePriceFeed(stocks: [])
        let vm = SymbolDetailViewModel(symbol: "BBB", feed: feed)

        vm.consume(.connection(.connected))

        #expect(vm.stock == nil)
    }
}
