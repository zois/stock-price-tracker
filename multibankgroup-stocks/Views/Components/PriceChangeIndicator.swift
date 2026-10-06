//
//  PriceChangeIndicator.swift
//  multibankgroup-stocks
//
//  Created by Zois Avgerinos on 5/10/26.
//

import SwiftUI

// MARK: - PriceChangeIndicator -

struct PriceChangeIndicator: View {
    let changePercent: Double

    private var isFlat: Bool { abs(changePercent) < 0.000_1 }

    var body: some View {
        Group {
            if isFlat {
                Text("0%")
                    .foregroundStyle(.secondary)
            } else {
                HStack(spacing: 4) {
                    Image(systemName: changePercent > 0 ? "arrow.up.right" : "arrow.down.right")
                    Text("\(changePercent.formatted(.number.precision(.fractionLength(2))))%")
                }
                .foregroundStyle(changePercent > 0 ? .green : .red)
            }
        }
        .font(.subheadline.monospacedDigit())
    }
}
