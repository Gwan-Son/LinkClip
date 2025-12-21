//
//  CategoryChip.swift
//  LinkClip
//
//  Created by 심관혁 on 12/10/25.
//

import SwiftUI

struct CategoryChip: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(isSelected ? .white : color)

                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? color : color.opacity(0.1))
                    .overlay(
                        Capsule()
                            .stroke(
                                isSelected ? .clear : color.opacity(0.3),
                                lineWidth: 1
                            )
                    )
            )
        }
    }
}

#Preview {
    CategoryChip(
        title: "테스트 카테고리",
        icon: "folder",
        color: .blue,
        isSelected: false
    ) {
        print("Category chip tapped")
    }
}

