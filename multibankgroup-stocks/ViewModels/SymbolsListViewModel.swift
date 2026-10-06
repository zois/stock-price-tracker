//
//  SymbolsListViewModel.swift
//  multibankgroup-stocks
//
//  Created by Zois Avgerinos on 5/10/26.
//

import Observation

// MARK: - SymbolsListViewModel -

/// List screen state. Observes the feed and owns sorting / start-stop.
@MainActor
@Observable
final class SymbolsListViewModel {

    // MARK: - UI state -

    private(set) var stocks: [Stock] = []
    private(set) var connectionStatus: ConnectionStatus = .disconnected
    var sortOption: SortOption = .price

    var sortedStocks: [Stock] {
        switch sortOption {
        case .price:
            stocks.sorted {
                if $0.price != $1.price { return $0.price > $1.price }
                return $0.symbol < $1.symbol
            }
        case .priceChange:
            stocks.sorted {
                if $0.changePercent != $1.changePercent {
                    return $0.changePercent > $1.changePercent
                }
                return $0.symbol < $1.symbol
            }
        }
    }

    var isConnected: Bool { connectionStatus == .connected }

    // MARK: - Dependencies -

    private let feed: any PriceFeedServicing
    private let onSelectSymbol: (String) -> Void

    // MARK: - Init -

    init(
        feed: any PriceFeedServicing,
        onSelectSymbol: @escaping (String) -> Void
    ) {
        self.feed = feed
        self.onSelectSymbol = onSelectSymbol
    }

    // MARK: - Feed control -

    func start() async {
        await feed.start()
    }

    func stop() async {
        await feed.stop()
    }

    func toggleFeed() async {
        if isConnected {
            await stop()
        } else {
            await start()
        }
    }

    // MARK: - Navigation -

    func selectSymbol(_ symbol: String) {
        onSelectSymbol(symbol)
    }

    // MARK: - Listening -

    /// Called from the view's `.task` so SwiftUI cancels when the view goes away.
    func listenForEvents() async {
        let stream = await feed.makeEventStream()
        for await event in stream {
            consume(event)
        }
    }

    /// Applies a feed event to list UI state.
    func consume(_ event: PriceFeedEvent) {
        switch event {
        case .connection(let status):
            connectionStatus = status
        case .stocks(let stocks):
            self.stocks = stocks
        }
    }
}
