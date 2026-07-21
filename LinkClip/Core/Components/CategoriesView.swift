//
//  HomeCategoriesView.swift
//  LinkClip
//
//  Created by 심관혁 on 12/16/25.
//

import SwiftUI

struct HomeCategoriesView: View {
    @ObservedObject var viewModel: HomeViewModel
    let isEditing: Bool
    let onAddCategoryTap: () -> Void
    let onCategoryManagementTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Picker("링크 모음", selection: $viewModel.librarySection) {
                Text("보관함").tag(LibrarySection.library)
                Text("나중에 읽기").tag(LibrarySection.readLater)
                Text("즐겨찾기").tag(LibrarySection.favorites)
            }
            .pickerStyle(.segmented)
            .tint(.mainColor)
            .padding(.horizontal, 20)

            VStack(alignment: .leading, spacing: 10) {
                Text("빠른 필터")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 20)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                    TagCapsule(
                        title: "요약 완료",
                        icon: "sparkles",
                        count: viewModel.summarizedCount,
                        color: .mainColor,
                        isSelected: viewModel.linkFilter == .summarized
                    ) {
                        if viewModel.linkFilter == .summarized {
                            viewModel.linkFilter = .all
                        } else {
                            viewModel.selectedCategory = nil
                            viewModel.linkFilter = .summarized
                        }
                    }

                    TagCapsule(
                        title: "읽지 않음",
                        icon: "circle.fill",
                        count: viewModel.unreadCount,
                        color: .mainColor,
                        isSelected: viewModel.linkFilter == .unread
                    ) {
                        if viewModel.linkFilter == .unread {
                            viewModel.linkFilter = .all
                        } else {
                            viewModel.selectedCategory = nil
                            viewModel.linkFilter = .unread
                        }
                    }

                    TagCapsule(
                        title: "미분류",
                        icon: "tag.slash",
                        count: viewModel.uncategorizedCount,
                        color: .mainColor,
                        isSelected: viewModel.linkFilter == .uncategorized
                    ) {
                        if viewModel.linkFilter == .uncategorized {
                            viewModel.linkFilter = .all
                        } else {
                            viewModel.selectedCategory = nil
                            viewModel.linkFilter = .uncategorized
                        }
                    }

                    TagCapsule(
                        title: "최근 7일",
                        icon: "calendar",
                        count: viewModel.recentCount,
                        color: .mainColor,
                        isSelected: viewModel.linkFilter == .recent
                    ) {
                        if viewModel.linkFilter == .recent {
                            viewModel.linkFilter = .all
                        } else {
                            viewModel.selectedCategory = nil
                            viewModel.linkFilter = .recent
                        }
                    }

                    }
                    .padding(.horizontal, 20)
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("태그")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Spacer()

                    Button(action: onCategoryManagementTap) {
                        Image(systemName: "tag")
                    }
                    .accessibilityLabel("태그 관리")

                    Menu {
                        Picker("정렬 옵션", selection: $viewModel.sortOption) {
                            ForEach(SortOption.allCases) { option in
                                Text(option.displayName).tag(option)
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                    .accessibilityLabel("정렬 옵션")
                }
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 20)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                    ForEach(viewModel.categories, id: \.id) { category in
                        let color = Color(hex: category.safeColor)
                        let linkCount = category.links?.count ?? 0

                        TagCapsule(
                            title: category.name,
                            icon: category.icon,
                            count: linkCount,
                            color: color,
                            isSelected: viewModel.selectedCategory?.id == category.id
                        ) {
                            if viewModel.selectedCategory?.id == category.id {
                                viewModel.selectedCategory = nil
                            } else {
                                viewModel.linkFilter = .all
                                viewModel.selectedCategory = category
                            }
                        }
                    }

                    if !isEditing {
                        Button(action: onAddCategoryTap) {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color.mainColor)
                                .frame(width: 40, height: 40)
                                .background(Color.mainColor.opacity(0.12), in: Circle())
                        }
                        .accessibilityLabel(
                            String(localized: "nav_new_category", defaultValue: "새 카테고리")
                        )
                    }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .padding(.bottom, 8)
    }
}
