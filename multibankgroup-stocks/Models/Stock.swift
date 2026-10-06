//
//  Stock.swift
//  multibankgroup-stocks
//
//  Created by Zois Avgerinos on 5/10/26.
//

// MARK: - Stock -

/// Domain model.
/// One symbol as we show it in the list / detail screens.
/// Prices get overwritten when the echo WebSocket sends an update back.
nonisolated struct Stock: Identifiable, Hashable, Sendable {
    let symbol: String
    let name: String
    let description: String
    var price: Double
    var previousPrice: Double

    var id: String { symbol }

    /// Absolute move since the last applied update.
    var priceChange: Double { price - previousPrice }

    var isPositive: Bool { priceChange > 0}

    var changePercent: Double {
        guard previousPrice != 0 else { return 0 }
        return (priceChange / previousPrice) * 100
    }
}

// MARK: - Mapping -

extension Stock {
    /// Apply an echoed price update. Domain owns how state changes.
    nonisolated mutating func apply(_ update: PriceUpdate) {
        guard update.symbol == symbol else { return }

        previousPrice = price
        price = update.price
    }
}
