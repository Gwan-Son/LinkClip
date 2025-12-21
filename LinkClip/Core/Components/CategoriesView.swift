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

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("태그")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                    .padding(.leading, 20)

                Spacer()

                // 태그(카테고리) 추가 버튼
                if !isEditing {
                    Button(action: onAddCategoryTap) {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                            .frame(width: 25, height: 25)
                            .background(
                                Circle()
                                    .fill(Color.white)
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                Color.black.opacity(0.05),
                                                lineWidth: 1
                                            )
                                    )
                            )
                    }
                }

                Menu {
                    Picker("정렬 옵션", selection: $viewModel.sortOption) {
                        ForEach(SortOption.allCases) { option in
                            Text(option.displayName)
                                .tag(option)
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down.circle")
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                        .frame(width: 25, height: 25)
                        .background(
                            Circle()
                                .fill(Color.white)
                                .overlay(
                                    Circle()
                                        .stroke(
                                            Color.black.opacity(0.05),
                                            lineWidth: 1
                                        )
                                )
                        )
                }
                .padding(.trailing, 20)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // 전체 태그 캡슐
                    TagCapsule(
                        title: String(localized: "전체", defaultValue: "전체"),
                        icon: "link",
                        count: viewModel.allLinks.count,
                        color: Color(hex: "6C757D"),
                        isSelected: viewModel.selectedCategory == nil
                    ) {
                        viewModel.selectedCategory = nil
                    }

                    // 카테고리 태그 캡슐들
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
                            viewModel.selectedCategory = category
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
            }
        }
    }
}
