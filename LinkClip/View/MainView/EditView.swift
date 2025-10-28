//
//  EditView.swift
//  LinkClip
//
//  Created by 심관혁 on 3/26/25.
//

import SwiftData
import SwiftUI

struct EditView: View {
    @Bindable var savedURL: LinkItem
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query private var categories: [CategoryItem]
    @State private var selectedCategory: CategoryItem?

    // personalMemo의 non-optional 버전을 위한 상태
    @State private var memoText: String

    init(savedURL: LinkItem) {
        self._savedURL = Bindable(savedURL)
        // 초기값 설정, nil이면 빈 문자열로 초기화
        self._memoText = State(initialValue: savedURL.personalMemo ?? "")
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(LocalizedStringResource("section_url_info", defaultValue: "URL 정보"))) {
                    Text(savedURL.url)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Section(header: Text(LocalizedStringResource("section_title", defaultValue: "제목"))) {
                    if #available(iOS 26.0, *) {
                        TextField(
                            LocalizedStringResource("ph_url_title", defaultValue: "URL 제목"), text: $savedURL.title
                        )
                    } else {
                        TextField(String(localized: "ph_url_title"), text: $savedURL.title)
                    }
                }

                Section(
                    header: Text(LocalizedStringResource("section_personal_memo", defaultValue: "개인 메모"))
                ) {
                    TextEditor(text: $memoText)
                        .frame(height: 100)
                }

                Section(header: Text(LocalizedStringResource("section_category", defaultValue: "카테고리"))) {
                    Picker(
                        LocalizedStringResource("picker_select_category", defaultValue: "카테고리 선택"),
                        selection: $selectedCategory
                    ) {
                        Text(LocalizedStringResource("none", defaultValue: "없음")).tag(nil as CategoryItem?)

                        // 상위 카테고리
                        ForEach(categories.filter { $0.parentCategory == nil }) { category in
                            Text(category.name).tag(category as CategoryItem?)
                        }

                        // 하위 카테고리
                        ForEach(categories.filter { $0.parentCategory != nil }) { subCategory in
                            if let parentName = subCategory.parentCategory?.name {
                                let format = String(localized: "%@ > %@")
                                Text(String(format: format, parentName, subCategory.name))
                                    .tag(subCategory as CategoryItem?)
                            }
                        }
                    }
                    .onChange(of: selectedCategory) { _, newValue in
                        savedURL.category = newValue
                    }
                    .onAppear {
                        selectedCategory = savedURL.category
                    }
                }
            }
            .navigationTitle(LocalizedStringResource("nav_edit_url", defaultValue: "URL 편집"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button(LocalizedStringResource("btn_cancel", defaultValue: "취소")) {
                    dismiss()
                },
                trailing: Button(LocalizedStringResource("btn_save", defaultValue: "저장")) {
                    savedURL.personalMemo = memoText.isEmpty ? nil : memoText
                    try? modelContext.save()
                    dismiss()
                }
            )
        }
    }
}

#Preview {
    EditView(savedURL: LinkItem(url: "https://www.google.com", title: "구글"))
}
