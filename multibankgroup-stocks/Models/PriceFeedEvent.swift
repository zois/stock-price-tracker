//
//  PriceFeedEvent.swift
//  multibankgroup-stocks
//
//  Created by Zois Avgerinos on 5/10/26.
//

// MARK: - PriceFeedEvent -

/// What ViewModels listen for. Keeps the service UI-agnostic.
nonisolated enum PriceFeedEvent: Sendable {
    case connection(ConnectionStatus)
    case stocks([Stock])
}
