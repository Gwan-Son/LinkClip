//
//  CategoryManagementView.swift
//  LinkClip
//
//  Created by 심관혁 on 4/11/25.
//

import SwiftData
import SwiftUI

struct CategoryManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CategoryItem.createdDate, order: .forward) private var fetchedCategories: [CategoryItem]
    @Environment(\.dismiss) private var dismiss

    var onCategoryDeleted: ((CategoryItem) -> Void)? = nil
    var onOrderChanged: (() -> Void)? = nil

    @State private var selectedCategory: CategoryItem? = nil
    @State private var showingEditView = false

    private var categories: [CategoryItem] {
        let order = Dictionary(uniqueKeysWithValues: UserDefaults.shared.categoryOrder.enumerated().map { ($1, $0) })
        return fetchedCategories.sorted { (order[$0.id] ?? .max) < (order[$1.id] ?? .max) }
    }

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text(LocalizedStringResource("카테고리 목록", defaultValue: "Category List"))) {
                    ForEach(categories) { category in
                        HStack {
                            Circle()
                                .fill(Color(hex: category.safeColor))
                                .frame(width: 12, height: 12)

                            Image(systemName: category.icon)
                                .foregroundColor(Color(hex: category.safeColor))

                            VStack(alignment: .leading) {
                                Text(category.name)
                                    .font(.headline)

                                if let linkCount = category.links?.count {
                                    Text("\(linkCount)개의 링크")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedCategory = category
                            // 약간의 딜레이 후 sheet 표시 (selectedCategory가 설정될 시간을 줌)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    showingEditView = true
                                }
                            }
                        }
                    }
                    .onDelete(perform: deleteCategories)
                    .onMove(perform: moveCategories)
                }
            }
            .navigationTitle(LocalizedStringResource("카테고리 관리", defaultValue: "Category Management"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { EditButton() }
            .sheet(isPresented: $showingEditView, onDismiss: {
                selectedCategory = nil
                showingEditView = false
            }) {
                Group {
                    if let category = selectedCategory {
                        CategoryEditView(category: category) { updatedCategory in
                            // 카테고리 수정 완료 처리
                            print("카테고리 수정 완료: \(updatedCategory.name)")
                        }
                    } else {
                        // 로딩 중 표시 (애니메이션 시간 동안)
                        ProgressView("로딩 중...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            .id(selectedCategory?.id)
        }
    }

    private func saveCategory(name: String, icon: String, colorHex: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        // 중복 이름 체크
        let existingCategory = categories.first {
            $0.name.lowercased() == trimmedName.lowercased()
        }
        guard existingCategory == nil else {
            // 중복 알림은 View에서 처리
            return
        }

        let newCategory = CategoryItem(
            name: trimmedName,
            icon: icon,
            color: colorHex
        )
        modelContext.insert(newCategory)

        do {
            try modelContext.save()
        } catch {
            print("카테고리 저장 실패: \(error)")
        }
    }

    private func deleteCategories(at offsets: IndexSet) {
        for index in offsets {
            let category = categories[index]
            modelContext.delete(category)
            // 삭제 완료 후 콜백 호출 (삭제된 카테고리 전달)
            onCategoryDeleted?(category)
        }
        do {
            try modelContext.save()
        } catch {
            print("카테고리 삭제 실패: \(error)")
        }
    }

    private func moveCategories(from source: IndexSet, to destination: Int) {
        var reordered = categories
        reordered.move(fromOffsets: source, toOffset: destination)
        UserDefaults.shared.categoryOrder = reordered.map(\.id)
        onOrderChanged?()
    }
}

#Preview {
    CategoryManagementView()
}
