//
//  StatBlockView.swift
//  App Game
//
//  Shared stat display used across game modes.
//

import SwiftUI

struct StatBlock: View {
    let title: String
    let value: String
    var isWarning: Bool = false

    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white.opacity(0.9))
            Text(value)
                .font(.system(size: 32, weight: .bold))
                .monospacedDigit()
                .foregroundStyle(isWarning ? .red : .white)
        }
        .padding(12)
        .background(.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        StatBlock(title: "Score", value: "42")
    }
}
