//
//  HomeLinksView.swift
//  LinkClip
//
//  Created by 심관혁 on 12/16/25.
//

import SwiftUI

struct HomeLinksView: View {
    @ObservedObject var viewModel: HomeViewModel
    @ObservedObject var state: HomeState
    let onEditLink: (LinkItem) -> Void
    let onSummarize: (LinkItem) -> Void
    let onReminder: (LinkItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !state.isEditing && !viewModel.allLinks.isEmpty {
                HStack {
                    Text("링크")
                        .font(.headline)

                    Spacer()

                    Text(
                        String(
                            format: String(localized: "%lld개의 링크"),
                            viewModel.filteredLinks.count
                        )
                    )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 20)
            }

            LazyVStack(spacing: 12) {
                    if viewModel.filteredLinks.isEmpty {
                        ContentUnavailableView(
                            viewModel.isSearching ? "검색 결과가 없습니다" :
                            viewModel.selectedCategory != nil ? "이 태그에 링크가 없습니다" :
                            "저장된 링크가 없습니다",
                            systemImage: viewModel.isSearching ? "magnifyingglass" : "tray",
                            description: Text(
                                viewModel.isSearching ?
                                LocalizedStringResource("다른 검색어를 입력해보세요", defaultValue: "다른 검색어를 입력해보세요") :
                                viewModel.selectedCategory != nil ?
                                LocalizedStringResource("다른 태그를 선택해보세요", defaultValue: "다른 태그를 선택해보세요") :
                                LocalizedStringResource("공유 버튼으로 나중에 읽을 링크를 모아보세요.", defaultValue: "공유 버튼으로 나중에 읽을 링크를 모아보세요.")
                            )
                        )
                        .frame(maxWidth: .infinity, minHeight: 200)
                    } else {
                        ForEach(
                            viewModel.filteredLinks,
                            id: \.id
                        ) { link in
                            if state.isEditing {
                                // 편집 모드: 선택 가능한 행
                                HStack {
                                    // 선택 체크박스
                                    Button {
                                        state.toggleLinkSelection(link)
                                    } label: {
                                        Image(
                                            systemName: state.selectedLinks
                                                .contains(link) ? "checkmark.circle.fill" : "circle"
                                        )
                                        .font(.system(size: 20))
                                        .foregroundColor(
                                            state.selectedLinks
                                                .contains(link) ? .mainColor : .gray
                                        )
                                        .frame(width: 44, height: 44)
                                    }

                                    // 링크 내용
                                    LinkRow(
                                        link: link,
                                        isRead: viewModel.isRead(link),
                                        isReadLater: viewModel.isReadLater(link)
                                    ) {
                                        // 전체 행의 탭 제스처에서 선택 처리
                                    } onCopy: {
                                        // 편집 모드에서는 복사 비활성화
                                    } onEdit: {
                                        // 편집 모드에서는 수정 비활성화
                                    } onDelete: {
                                        // 편집 모드에서는 개별 삭제 비활성화
                                    }

                                    Spacer()
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    state.toggleLinkSelection(link)
                                }
                            } else {
                                // 일반 모드: 기존 기능 유지
                                LinkRow(
                                    link: link,
                                    searchText: viewModel.searchText,
                                    isFavorite: viewModel.isFavorite(link),
                                    isRead: viewModel.isRead(link),
                                    isReadLater: viewModel.isReadLater(link)
                                ) {
                                    if let url = URL(string: link.url) {
                                        viewModel.markRead(link)
                                        UIApplication.shared.open(url)
                                    }
                                } onCopy: {
                                    UIPasteboard.general.string = link.url
                                    withAnimation { state.showingCopiedToast = true }
                                } onEdit: {
                                    onEditLink(link)
                                } onDelete: {
                                    state.linkPendingDeletion = link
                                } onFavorite: {
                                    viewModel.toggleFavorite(link)
                                } onRead: {
                                    viewModel.toggleRead(link)
                                } onReadLater: {
                                    viewModel.toggleReadLater(link)
                                } onReminder: {
                                    onReminder(link)
                                } onSummary: {
                                    onSummarize(link)
                                }
                                .id(link.id)
                            }

                        }
                    }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, state.isEditing ? 100 : 32)
        }
    }
}
