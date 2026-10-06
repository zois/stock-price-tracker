//
//  FakePriceFeed.swift
//  multibankgroup-stocks
//
//  Created by Zois Avgerinos on 6/10/26.
//

import Foundation
@testable import multibankgroup_stocks

// MARK: - FakePriceFeed -

actor FakePriceFeed: PriceFeedServicing {
    private(set) var stocks: [Stock]
    private(set) var connectionStatus: ConnectionStatus = .disconnected
    private(set) var startCallCount = 0
    private(set) var stopCallCount = 0

    init(stocks: [Stock]) {
        self.stocks = stocks
    }

    func stock(for symbol: String) -> Stock? {
        stocks.first { $0.symbol == symbol }
    }

    func makeEventStream() -> AsyncStream<PriceFeedEvent> {
        AsyncStream { _ in }
    }

    func start() {
        startCallCount += 1
        connectionStatus = .connected
    }

    func stop() {
        stopCallCount += 1
        connectionStatus = .disconnected
    }

    func emit(stocks: [Stock]) {
        self.stocks = stocks
    }
}
