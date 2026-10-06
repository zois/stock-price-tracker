//
//  multibankgroup_stocksApp.swift
//  multibankgroup-stocks
//
//  Created by Zois Avgerinos on 5/10/26.
//

import SwiftUI

@main
struct multibankgroup_stocksApp: App {
    @State private var feed = PriceFeedService()
    @State private var coordinator = AppCoordinator()
    @State private var listViewModel: SymbolsListViewModel?

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $coordinator.path) {
                Group {
                    if let listViewModel {
                        SymbolsListView(viewModel: listViewModel)
                    }
                }
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .detail(let symbol):
                        SymbolDetailView(
                            viewModel: SymbolDetailViewModel(
                                symbol: symbol,
                                feed: feed
                            )
                        )
                    }
                }
            }
            .background(Color("LaunchBackground"))
            .preferredColorScheme(.dark)
            .task {
                if listViewModel == nil {
                    listViewModel = SymbolsListViewModel(
                        feed: feed,
                        onSelectSymbol: { symbol in
                            coordinator.showDetail(symbol: symbol)
                        }
                    )
                }
            }
        }
    }
}
