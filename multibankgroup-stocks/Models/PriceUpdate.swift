//
//  PriceUpdate.swift
//  multibankgroup-stocks
//
//  Created by Zois Avgerinos on 5/10/26.
//

// MARK: - PriceUpdate -

/// Payload we send to the echo socket and get right back.
nonisolated struct PriceUpdate: Codable, Sendable {
    let symbol: String
    let price: Double
}
