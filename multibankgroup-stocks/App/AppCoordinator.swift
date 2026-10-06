//
//  AppCoordinator.swift
//  multibankgroup-stocks
//
//  Created by Zois Avgerinos on 5/10/26.
//

import SwiftUI

// MARK: - AppCoordinator -

/// Owns the navigation stack. Views don't push destinations themselves.
@MainActor
@Observable
final class AppCoordinator {
    var path = NavigationPath()

    func showDetail(symbol: String) {
        path.append(AppRoute.detail(symbol: symbol))
    }

    func popToRoot() {
        path = NavigationPath()
    }
}
