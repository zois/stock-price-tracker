//
//  ConnectionBanner.swift
//  multibankgroup-stocks
//
//  Created by Zois Avgerinos on 5/10/26.
//

import SwiftUI

// MARK: - ConnectionBanner -

struct ConnectionBanner: View {
    let status: ConnectionStatus

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(status == .connected ? Color.green : Color.red)
                .frame(width: 8, height: 8)
            Text(status == .connected ? "Connected" : "Disconnected")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
        }
        .accessibilityElement(children: .combine)
    }
}
