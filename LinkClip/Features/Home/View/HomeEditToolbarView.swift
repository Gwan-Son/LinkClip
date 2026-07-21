//
//  HomeEditToolbarView.swift
//  LinkClip
//
//  Created by 심관혁 on 12/16/25.
//

import SwiftUI

enum HomeBatchAction {
    case markRead, markUnread
    case addToReadLater, removeFromReadLater
    case addToFavorites, removeFromFavorites
}

struct HomeEditToolbarView: View {
    @ObservedObject var state: HomeState
    @State private var showingBatchActions = false
    let onBatchAction: (HomeBatchAction) -> Void
    let onShareAttempt: () -> Void
    let onDeleteAttempt: () -> Void

    var body: some View {
        VStack {
            Spacer()
            HStack(spacing: 0) {
                Button(action: onShareAttempt) {
                    Label("공유", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .disabled(state.selectedLinks.isEmpty)

                Button {
                    showingBatchActions = true
                } label: {
                    Label("더보기", systemImage: "ellipsis.circle")
                        .frame(maxWidth: .infinity)
                }
                .disabled(state.selectedLinks.isEmpty)

                Button(action: onDeleteAttempt) {
                    Label("삭제", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
                .tint(.red)
                .disabled(state.selectedLinks.isEmpty)
            }
            .font(.subheadline.weight(.semibold))
            .labelStyle(.titleAndIcon)
            .tint(.mainColor)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background {
                Color.cardBackground
                    .shadow(
                        color: Color.black.opacity(0.1),
                        radius: 8,
                        x: 0,
                        y: -4
                    )
                    .ignoresSafeArea(edges: .bottom)
            }
            .transition(.move(edge: .bottom))
        }
        .ignoresSafeArea(.keyboard)
        .confirmationDialog(
            "\(state.selectedLinks.count)개 선택됨",
            isPresented: $showingBatchActions,
            titleVisibility: .visible
        ) {
            Button("읽음으로 표시") { onBatchAction(.markRead) }
            Button("읽지 않음으로 표시") { onBatchAction(.markUnread) }
            Button("나중에 읽기") { onBatchAction(.addToReadLater) }
            Button("나중에 읽기 해제") { onBatchAction(.removeFromReadLater) }
            Button("즐겨찾기") { onBatchAction(.addToFavorites) }
            Button("즐겨찾기 해제") { onBatchAction(.removeFromFavorites) }
            Button("취소", role: .cancel) { }
        }
    }
}
