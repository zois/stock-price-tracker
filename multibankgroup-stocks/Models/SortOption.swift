//
//  SortOption.swift
//  multibankgroup-stocks
//
//  Created by Zois Avgerinos on 5/10/26.
//

// MARK: - SortOption -

/// How the symbols list is ordered.
nonisolated enum SortOption: String, CaseIterable, Identifiable, Sendable {
    case price = "Price"
    case priceChange = "Price Change"

    var id: String { rawValue }
}
