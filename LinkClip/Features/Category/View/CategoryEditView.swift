//
//  CategoryEditView.swift
//  LinkClip
//
//  Created by 심관혁 on 4/11/25.
//

import SwiftUI
import SwiftData

struct CategoryEditView: View {
    let category: CategoryItem
    let onCategoryUpdated: (CategoryItem) -> Void

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \CategoryItem.createdDate, order: .forward) private var categories: [CategoryItem]

    @State private var categoryName: String
    @State private var selectedIcon: String
    @State private var selectedColor: String
    @State private var showColorPalette: Bool = false
    @State private var showingDuplicateAlert = false
    @State private var showingDeleteAlert = false

    let icons = [
        "folder", "tag", "bookmark", "link", "doc", "newspaper", "book",
        "graduationcap", "briefcase", "cart", "creditcard", "heart",
        "house", "car", "airplane", "gamecontroller", "tv", "music.note",
        "photo", "person", "globe",
    ]

    init(category: CategoryItem, onCategoryUpdated: @escaping (CategoryItem) -> Void) {
        self.category = category
        self.onCategoryUpdated = onCategoryUpdated
        _categoryName = State(initialValue: category.name)
        _selectedIcon = State(initialValue: category.icon)
        _selectedColor = State(initialValue: category.safeColor)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 카테고리 이름 입력
                    VStack(alignment: .leading, spacing: 8) {
                        Text("카테고리 이름")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)

                        TextField("카테고리 이름을 입력하세요", text: $categoryName)
                            .font(.system(size: 16))
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }

                    // 현재 선택된 아이콘 미리보기
                    VStack(alignment: .leading, spacing: 8) {
                        Text("현재 아이콘")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)

                        HStack {
                            Circle()
                                .fill(Color(hex: selectedColor))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(systemName: selectedIcon)
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                )

                            VStack(alignment: .leading) {
                                Text("미리보기")
                                    .font(.system(size: 14, weight: .medium))
                                Text("색상과 아이콘의 조합")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }

                    // 아이콘 선택
                    VStack(alignment: .leading, spacing: 16) {
                        Text("아이콘 선택")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 16) {
                            ForEach(icons, id: \.self) { icon in
                                Button {
                                    selectedIcon = icon
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(selectedIcon == icon ? Color(hex: selectedColor) : Color.gray.opacity(0.2))
                                            .frame(width: 44, height: 44)

                                        Image(systemName: icon)
                                            .font(.system(size: 20))
                                            .foregroundColor(selectedIcon == icon ? .white : .primary)
                                    }
                                }
                            }
                        }
                    }

                    // 색상 선택
                    VStack(alignment: .leading, spacing: 16) {
                        Text("색상 선택")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)

                        Button {
                            showColorPalette.toggle()
                        } label: {
                            HStack {
                                Circle()
                                    .fill(Color(hex: selectedColor))
                                    .frame(width: 30, height: 30)

                                Text("색상 선택하기")
                                    .foregroundColor(.primary)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .navigationTitle(LocalizedStringResource("카테고리 수정", defaultValue: "Edit Category"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(LocalizedStringResource("btn_cancel", defaultValue: "Cancel")) {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizedStringResource("저장", defaultValue: "Save")) {
                        updateCategory()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.blue)
                    .disabled(categoryName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .sheet(isPresented: $showColorPalette) {
                ColorPaletteView(selectedColor: $selectedColor)
            }
            .alert("중복된 카테고리 이름", isPresented: $showingDuplicateAlert) {
                Button("취소", role: .cancel) { }
            } message: {
                Text("이미 존재하는 카테고리 이름입니다.\n다른 이름을 입력해주세요.")
            }
            .alert("카테고리 삭제", isPresented: $showingDeleteAlert) {
                Button("취소", role: .cancel) { }
                Button("삭제", role: .destructive) {
                    deleteCategory()
                }
            } message: {
                if let linkCount = category.links?.count, linkCount > 0 {
                    Text("이 카테고리에는 \(linkCount)개의 링크가 있습니다. 삭제하면 링크들은 '전체' 카테고리로 이동합니다.\n\n정말 삭제하시겠습니까?")
                } else {
                    Text("카테고리를 삭제하시겠습니까?")
                }
            }
        }
        .onAppear {
            // State 변수들이 제대로 초기화되었는지 확인
            if categoryName.isEmpty {
                categoryName = category.name
            }
            if selectedIcon != category.icon {
                selectedIcon = category.icon
            }
            if selectedColor != category.safeColor {
                selectedColor = category.safeColor
            }
        }
    }

    private func updateCategory() {
        let trimmedName = categoryName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        // 중복 이름 체크 (자기 자신 제외)
        let existingCategory = categories.first {
            $0.id != category.id && $0.name.lowercased() == trimmedName.lowercased()
        }
        guard existingCategory == nil else {
            showingDuplicateAlert = true
            return
        }

        do {
            // 카테고리 업데이트
            category.name = trimmedName
            category.icon = selectedIcon
            category.color = selectedColor

            try modelContext.save()

            onCategoryUpdated(category)
            dismiss()
        } catch {
            print("카테고리 수정 실패: \(error)")
        }
    }

    private func deleteCategory() {
        do {
            modelContext.delete(category)
            try modelContext.save()
            dismiss()
        } catch {
            print("카테고리 삭제 실패: \(error)")
        }
    }
}
