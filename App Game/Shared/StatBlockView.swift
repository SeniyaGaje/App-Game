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
    var compact: Bool = false   // smaller variant for 4-column rows

    var body: some View {
        VStack(spacing: compact ? 4 : 8) {
            Text(title)
                .font(compact ? .system(size: 9, weight: .semibold) : .caption.weight(.semibold))
                .textCase(.uppercase)
                .tracking(compact ? 0.8 : 1)
                .foregroundStyle(.white.opacity(0.65))
            Text(value)
                .font(compact
                      ? .system(size: 20, weight: .bold, design: .rounded)
                      : .system(size: 30, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(isWarning ? .red : .white)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, minHeight: compact ? 54 : 84)
        .padding(.vertical, compact ? 8 : 14)
        .padding(.horizontal, compact ? 6 : 10)
        .background(Color(red: 0.10, green: 0.12, blue: 0.22), in: RoundedRectangle(cornerRadius: compact ? 14 : 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: compact ? 14 : 18, style: .continuous)
                .stroke(.white.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 4)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack(spacing: 12) {
            StatBlock(title: "Score", value: "42")
            StatBlock(title: "Score", value: "42", compact: true)
        }
        .padding()
    }
}
