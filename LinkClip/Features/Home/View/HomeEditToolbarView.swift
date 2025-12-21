//
//  HomeEditToolbarView.swift
//  LinkClip
//
//  Created by 심관혁 on 12/16/25.
//

import SwiftUI

struct HomeEditToolbarView: View {
    @ObservedObject var state: HomeState
    let filteredLinks: [LinkItem]
    let onSelectAllToggle: () -> Void
    let onShareAttempt: () -> Void
    let onDeleteAttempt: () -> Void

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Button(action: onSelectAllToggle) {
                    Text(state.selectedLinks.isEmpty ?
                         LocalizedStringResource("모두 선택", defaultValue: "모두 선택") :
                         LocalizedStringResource("모두 해제", defaultValue: "모두 해제"))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                }

                Spacer()

                Text("\(state.selectedLinks.count)개 선택됨")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)

                Spacer()

                Button(action: onShareAttempt) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(state.selectedLinks.isEmpty ? .secondary : .blue)
                }

                Spacer()

                Button(action: onDeleteAttempt) {
                    Text(LocalizedStringResource("삭제", defaultValue: "삭제"))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(
                            state.selectedLinks.isEmpty ? .secondary : .red
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                Color.white
                    .shadow(
                        color: Color.black.opacity(0.1),
                        radius: 8,
                        x: 0,
                        y: -4
                    )
            )
            .transition(.move(edge: .bottom))
        }
        .ignoresSafeArea(.keyboard)
    }
}
