//
//  SymbolDetailView.swift
//  multibankgroup-stocks
//
//  Created by Zois Avgerinos on 6/10/26.
//

import SwiftUI

// MARK: - SymbolDetailView -

struct SymbolDetailView: View {
    @Bindable var viewModel: SymbolDetailViewModel

    var body: some View {
        Group {
            if let stock = viewModel.stock {
                content(for: stock)
            } else {
                ContentUnavailableView(
                    "Symbol unavailable",
                    systemImage: "chart.line.downtrend.xyaxis",
                    description: Text("No data for \(viewModel.symbol).")
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("LaunchBackground"))
        .navigationTitle(viewModel.symbol)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("LaunchBackground"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .task {
            await viewModel.listenForEvents()
        }
    }
}

// MARK: - Private -

private extension SymbolDetailView {

    func content(for stock: Stock) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(stock.name)
                    .font(.title2.weight(.semibold))

                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    Text(stock.price, format: .number.precision(.fractionLength(2)))
                        .font(.largeTitle.monospacedDigit().weight(.bold))

                    PriceChangeIndicator(changePercent: stock.changePercent)
                }

                Text(stock.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .background(Color("LaunchBackground"))
    }
}
