//
//  HomeHeaderView.swift
//  LinkClip
//
//  Created by 심관혁 on 12/16/25.
//

import SwiftUI

struct HomeHeaderView: View {
    let isEditing: Bool
    let selectedCount: Int
    let areAllSelected: Bool
    let canEdit: Bool
    let onSearchTap: () -> Void
    let onEditingTap: () -> Void
    let onSelectAllTap: () -> Void
    let onSettingsTap: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            if isEditing {
                Button("취소", action: onEditingTap)

                Spacer()

                Text("\(selectedCount)개 선택")
                    .font(.headline)

                Spacer()

                Button(areAllSelected ? "모두 해제" : "모두 선택", action: onSelectAllTap)
                    .font(.subheadline.weight(.semibold))
            } else {
                Text("보관함")
                    .font(.system(size: 30, weight: .bold, design: .rounded))

                Spacer()

                Button(action: onSearchTap) {
                    Image(systemName: "magnifyingglass")
                }
                .accessibilityLabel("검색")

                Button("선택", action: onEditingTap)
                    .font(.subheadline.weight(.semibold))
                    .disabled(!canEdit)

                Button(action: onSettingsTap) {
                    Image(systemName: "gearshape")
                }
                .accessibilityLabel("설정")
            }
        }
        .buttonStyle(.plain)
        .tint(.mainColor)
        .frame(minHeight: 44)
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 12)
        .background(Color.appBackground)
    }
}
