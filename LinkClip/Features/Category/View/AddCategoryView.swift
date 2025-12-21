//
//  AddCategoryView.swift
//  LinkClip
//
//  Created by 심관혁 on 4/11/25.
//

import SwiftUI
import SwiftData

struct AddCategoryView: View {
    let categories: [CategoryItem]
    let onSave: (String, String, String) -> Void
    let editingCategory: CategoryItem?

    @State private var categoryName: String = ""
    @State private var selectedIcon = "folder"
    @State private var selectedColor: String = randomColor()
    @State private var showColorPalette: Bool = false
    @Environment(\.dismiss) private var dismiss
    @State private var showingDuplicateAlert = false

    private var isEditing: Bool {
        editingCategory != nil
    }

    private var navigationTitle: LocalizedStringResource {
        isEditing ? LocalizedStringResource("카테고리 수정", defaultValue: "Edit Category") : LocalizedStringResource("nav_new_category", defaultValue: "새 카테고리")
    }

    let icons = [
        "folder", "tag", "bookmark", "link", "doc", "newspaper", "book",
        "graduationcap", "briefcase", "cart", "creditcard", "heart",
        "house", "car", "airplane", "gamecontroller", "tv", "music.note",
        "photo", "person", "globe",
    ]

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

                    // 아이콘 선택
                    VStack(alignment: .leading, spacing: 16) {
                        Text("아이콘 선택")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 60), spacing: 12)], spacing: 12) {
                        ForEach(icons, id: \.self) { icon in
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                        .fill(selectedIcon == icon ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                                    .frame(width: 50, height: 50)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(selectedIcon == icon ? Color.blue : Color.clear, lineWidth: 2)
                                        )

                                Image(systemName: icon)
                                        .font(.system(size: 20))
                                    .foregroundColor(selectedIcon == icon ? .blue : .primary)
                            }
                            .onTapGesture {
                                selectedIcon = icon
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }

                    // 색상 선택
                    VStack(alignment: .leading, spacing: 16) {
                        Button {
                            showColorPalette.toggle()
                        } label: {
                            HStack {
                                Text("색상 선택")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)

                                Spacer()

                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(Color(hex: selectedColor))
                                        .frame(width: 20, height: 20)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                        )

                                    Image(systemName: showColorPalette ? "chevron.up" : "chevron.down")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }

                        if showColorPalette {
                            ColorPaletteView(
                                selectedColor: $selectedColor,
                                onColorSelected: { _ in
                                    // 선택 즉시 팔레트 닫기 (선택적)
                                    // showColorPalette = false
                                }
                            )
                            .transition(.opacity.combined(with: .slide))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(LocalizedStringResource("btn_cancel", defaultValue: "취소")) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        saveCategory()
                    }
                    .disabled(categoryName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .alert("중복된 카테고리 이름", isPresented: $showingDuplicateAlert) {
                Button("확인", role: .cancel) { }
            } message: {
                Text("이미 존재하는 카테고리 이름입니다.\n다른 이름을 입력해주세요.")
            }
        }
    }

    private func saveCategory() {
        let trimmedName = categoryName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        // 중복 이름 체크
        let existingCategory = categories.first { $0.name.lowercased() == trimmedName.lowercased() }
        guard existingCategory == nil else {
            showingDuplicateAlert = true
            return
        }

        onSave(trimmedName, selectedIcon, selectedColor)
        dismiss()
                        }

    private static func randomColor() -> String {
        let colors = [
            "FF6B6B", // 빨강
            "4ECDC4", // 청록
            "45B7D1", // 파랑
            "96CEB4", // 민트
            "FFEAA7", // 노랑
            "DDA0DD", // 자주
            "98D8C8", // 연두
            "F7DC6F", // 금색
            "BB8FCE", // 보라
            "85C1E9", // 하늘
            "F8C471", // 주황
            "82E0AA", // 라임
        ]
        return colors.randomElement() ?? "FF6B6B"
    }
}

//#Preview {
//    AddCategoryView(categories: [], onSave: { _, _, _ in }, editingCategory: <#CategoryItem?#>)
//}
