//
//  PriceFeedServicing.swift
//  multibankgroup-stocks
//
//  Created by Zois Avgerinos on 5/10/26.
//


// MARK: - StockQuoting -

/// Read-only access to live quotes.
/// Detail (and any future reader) can depend on this.
protocol StockQuoting: Actor {
    var stocks: [Stock] { get }

    func stock(for symbol: String) -> Stock?
    /// Fresh stream per caller so list and detail can both subscribe.
    func makeEventStream() -> AsyncStream<PriceFeedEvent>
}

// MARK: - PriceFeedControlling -

/// Connection lifecycle for the echo WebSocket feed.
protocol PriceFeedControlling: Actor {
    var connectionStatus: ConnectionStatus { get }
    
    func start()
    func stop()
}

// MARK: - PriceFeedServicing -

/// Full feed surface — list screen needs both quoting and control.
protocol PriceFeedServicing: StockQuoting, PriceFeedControlling {}
