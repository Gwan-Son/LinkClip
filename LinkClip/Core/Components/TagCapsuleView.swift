//
//  TagCapsuleView.swift
//  LinkClip
//
//  Created by 심관혁 on 12/16/25.
//

import SwiftUI

struct TagCapsule: View {
    let title: String
    let icon: String
    let count: Int
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 7) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(isSelected ? .white : color)

                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)

                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 12))
                        .foregroundColor(
                            isSelected ? .white.opacity(0.8) : .gray
                        )
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(
                Capsule()
                    .fill(isSelected ? color : Color.cardBackground)
            )
        }
        .buttonStyle(.plain)
    }
}
