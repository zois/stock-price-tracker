//
//  AppCoordinatorTests.swift
//  multibankgroup-stocks
//
//  Created by Zois Avgerinos on 6/10/26.
//

import Testing
import SwiftUI
@testable import multibankgroup_stocks

// MARK: - AppCoordinatorTests -

@Suite("AppCoordinator")
@MainActor
struct AppCoordinatorTests {

    @Test("showDetail increases the navigation path")
    func showDetailAppends() {
        let coordinator = AppCoordinator()
        #expect(coordinator.path.isEmpty)

        coordinator.showDetail(symbol: "AAPL")

        #expect(coordinator.path.count == 1)
    }

    @Test("popToRoot clears the path")
    func popToRootClears() {
        let coordinator = AppCoordinator()
        coordinator.showDetail(symbol: "AAPL")
        coordinator.showDetail(symbol: "MSFT")

        coordinator.popToRoot()

        #expect(coordinator.path.isEmpty)
    }
}
