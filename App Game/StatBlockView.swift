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
        VStack(spacing: 8) {
            Text(title)
                .font(.caption.weight(.semibold))
                .textCase(.uppercase)
                .tracking(1)
                .foregroundStyle(.white.opacity(0.7))
            Text(value)
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(isWarning ? .red : .white)
        }
        .frame(maxWidth: .infinity, minHeight: 84)
        .padding(.vertical, 14)
        .padding(.horizontal, 10)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(.white.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 6)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        StatBlock(title: "Score", value: "42")
    }
}
