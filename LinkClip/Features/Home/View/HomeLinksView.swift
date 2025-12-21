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

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ScrollView {
                LazyVStack(spacing: 12) {
                    if (state.isEditing ? viewModel.allLinks : viewModel.filteredLinks).isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "link.badge.plus")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary.opacity(0.5))

                            Text(
                                viewModel.selectedCategory != nil ?
                                LocalizedStringResource("이 태그에 링크가 없습니다", defaultValue: "이 태그에 링크가 없습니다") :
                                LocalizedStringResource("저장된 링크가 없습니다", defaultValue: "저장된 링크가 없습니다")
                            )
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)

                            if viewModel.selectedCategory != nil {
                                Text(LocalizedStringResource("다른 태그를 선택해보세요", defaultValue: "다른 태그를 선택해보세요"))
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary.opacity(0.7))
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 200)
                        .padding(.vertical, 40)
                    } else {
                        ForEach(state.isEditing ? viewModel.allLinks : viewModel.filteredLinks) { link in
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
                                                .contains(link) ? .blue : .gray
                                        )
                                        .frame(width: 44, height: 44)
                                    }

                                    // 링크 내용
                                    LinkRow(link: link) {
                                        // 편집 모드에서는 탭으로 선택/해제
                                        state.toggleLinkSelection(link)
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
                                LinkRow(link: link) {
                                    if let url = URL(string: link.url) {
                                        UIApplication.shared.open(url)
                                    }
                                } onCopy: {
                                    // 클립보드 복사 기능 구현
                                    UIPasteboard.general.string = link.url
                                } onEdit: {
                                    onEditLink(link)
                                } onDelete: {
                                    viewModel.deleteLink(link)
                                }
                            }

                            Divider()
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}
