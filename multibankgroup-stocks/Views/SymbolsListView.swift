//
//  SymbolsListView.swift
//  multibankgroup-stocks
//
//  Created by Zois Avgerinos on 5/10/26.
//

import SwiftUI

// MARK: - SymbolsListView -

struct SymbolsListView: View {
    @Bindable var viewModel: SymbolsListViewModel

    var body: some View {
        List(viewModel.sortedStocks) { stock in
            Button {
                viewModel.selectSymbol(stock.symbol)
            } label: {
                StockRowView(stock: stock)
            }
            .buttonStyle(.plain)
            .listRowBackground(Color("LaunchBackground"))
        }
        .listStyle(.plain)
        .contentMargins(.top, 10)
        .scrollContentBackground(.hidden)
        .background(Color("LaunchBackground"))
        .navigationTitle("Stocks")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("LaunchBackground"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(viewModel.isConnected ? "Stop" : "Start") {
                    Task { await viewModel.toggleFeed() }
                }
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            header
        }
        .task {
            await viewModel.listenForEvents()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            LabeledContent {
                ConnectionBanner(status: viewModel.connectionStatus)
                Spacer(minLength: 0)
            } label: {
                Text("Status")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
            }

            LabeledContent {
                HStack(spacing: 8) {
                    sortButton(option: .price, title: "Price", systemImage: "dollarsign")
                    sortButton(option: .priceChange, title: "Price Change", systemImage: "arrow.up.arrow.down")
                    Spacer(minLength: 0)
                }
            } label: {
                Text("Sort")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("LaunchBackground"))
    }

    private func sortButton(
        option: SortOption,
        title: String,
        systemImage: String
    ) -> some View {
        let selected = viewModel.sortOption == option
        let directionIcon = viewModel.sortDirection == .ascending
            ? "chevron.up"
            : "chevron.down"
        return Button {
            viewModel.selectSort(option)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: systemImage)
                Text(title)
                if selected {
                    Image(systemName: directionIcon)
                }
            }
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(selected ? Color.accentColor.opacity(0.15) : Color.clear)
            .clipShape(.capsule)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            selected
                ? "\(title), \(viewModel.sortDirection == .ascending ? "ascending" : "descending")"
                : title
        )
    }

}

// MARK: - StockRowView -

private struct StockRowView: View {
    let stock: Stock

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(stock.symbol)
                    .font(.headline)
                Text(stock.name)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(stock.price, format: .number.precision(.fractionLength(2)))
                    .font(.body.monospacedDigit())
                PriceChangeIndicator(changePercent: stock.changePercent)
            }
        }
        .contentShape(Rectangle())
    }
}
