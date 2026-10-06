//
//  ConnectionStatus.swift
//  multibankgroup-stocks
//
//  Created by Zois Avgerinos on 5/10/26.
//

// MARK: - ConnectionStatus -

/// Whether the price feed socket is up.
nonisolated enum ConnectionStatus: Equatable, Sendable {
    case connected
    case disconnected
}
