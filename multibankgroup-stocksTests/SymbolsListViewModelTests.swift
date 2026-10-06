//
//  SymbolsListViewModelTests.swift
//  multibankgroup-stocks
//
//  Created by Zois Avgerinos on 6/10/26.
//

import Testing
@testable import multibankgroup_stocks

// MARK: - SymbolsListViewModelTests -

@Suite("SymbolsListViewModel")
@MainActor
struct SymbolsListViewModelTests {

    private func sampleStocks() -> [Stock] {
        [
            Stock(symbol: "AAA", name: "A", description: "", price: 10, previousPrice: 10),
            Stock(symbol: "BBB", name: "B", description: "", price: 30, previousPrice: 20),
            Stock(symbol: "CCC", name: "C", description: "", price: 20, previousPrice: 25),
        ]
    }

    @Test("sorts by price descending, symbol as tiebreaker")
    func sortsByPrice() {
        let feed = FakePriceFeed(stocks: [])
        let vm = SymbolsListViewModel(feed: feed, onSelectSymbol: { _ in })

        vm.consume(.stocks(sampleStocks()))
        vm.sortOption = .price

        #expect(vm.sortedStocks.map(\.symbol) == ["BBB", "CCC", "AAA"])
    }

    @Test("sorts by change percent descending, symbol as tiebreaker")
    func sortsByChangePercent() {
        let feed = FakePriceFeed(stocks: [])
        let vm = SymbolsListViewModel(feed: feed, onSelectSymbol: { _ in })

        vm.consume(.stocks(sampleStocks()))
        vm.sortOption = .priceChange

        #expect(vm.sortedStocks.map(\.symbol) == ["BBB", "AAA", "CCC"])
    }

    @Test("equal price change keeps symbol order as tiebreaker")
    func equalChangeUsesSymbolTiebreaker() {
        let stocks = [
            Stock(symbol: "ZZZ", name: "Z", description: "", price: 10, previousPrice: 10),
            Stock(symbol: "AAA", name: "A", description: "", price: 50, previousPrice: 50),
        ]
        let feed = FakePriceFeed(stocks: [])
        let vm = SymbolsListViewModel(feed: feed, onSelectSymbol: { _ in })

        vm.consume(.stocks(stocks))
        vm.sortOption = .priceChange

        #expect(vm.sortedStocks.map(\.symbol) == ["AAA", "ZZZ"])
    }

    @Test("consume updates connection status")
    func consumeConnection() {
        let feed = FakePriceFeed(stocks: [])
        let vm = SymbolsListViewModel(feed: feed, onSelectSymbol: { _ in })

        vm.consume(.connection(.connected))

        #expect(vm.connectionStatus == .connected)
        #expect(vm.isConnected)
    }

    @Test("start and stop forward to the feed")
    func startStopForward() async {
        let feed = FakePriceFeed(stocks: sampleStocks())
        let vm = SymbolsListViewModel(feed: feed, onSelectSymbol: { _ in })

        await vm.start()
        #expect(await feed.startCallCount == 1)

        await vm.stop()
        #expect(await feed.stopCallCount == 1)
    }

    @Test("toggleFeed starts when disconnected and stops when connected")
    func toggleFeed() async {
        let feed = FakePriceFeed(stocks: [])
        let vm = SymbolsListViewModel(feed: feed, onSelectSymbol: { _ in })

        await vm.toggleFeed()
        #expect(await feed.startCallCount == 1)

        vm.consume(.connection(.connected))
        await vm.toggleFeed()
        #expect(await feed.stopCallCount == 1)
    }

    @Test("selectSymbol invokes navigation callback")
    func selectSymbolCallback() {
        var selected: String?
        let feed = FakePriceFeed(stocks: [])
        let vm = SymbolsListViewModel(feed: feed) { selected = $0 }

        vm.selectSymbol("BBB")

        #expect(selected == "BBB")
    }
}
