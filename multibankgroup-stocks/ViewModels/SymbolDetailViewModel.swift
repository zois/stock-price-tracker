//
//  SymbolDetailViewModel.swift
//  multibankgroup-stocks
//
//  Created by Zois Avgerinos on 6/10/26.
//

import Observation

// MARK: - SymbolDetailViewModel -

/// Detail screen state for one symbol. Reads quotes only — no start/stop.
@MainActor
@Observable
final class SymbolDetailViewModel {

    // MARK: - UI state -

    let symbol: String
    private(set) var stock: Stock?

    // MARK: - Dependencies -

    private let feed: any StockQuoting

    // MARK: - Init -

    init(symbol: String, feed: any StockQuoting) {
        self.symbol = symbol
        self.feed = feed
    }

    // MARK: - Listening -

    /// Keep price in sync while this screen is visible.
    func listenForEvents() async {
        let stream = await feed.makeEventStream()
        for await event in stream {
            consume(event)
        }
    }

    func consume(_ event: PriceFeedEvent) {
        switch event {
        case .connection:
            break
        case .stocks(let stocks):
            stock = stocks.first { $0.symbol == symbol }
        }
    }
}
