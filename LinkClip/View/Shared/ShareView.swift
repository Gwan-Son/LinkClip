//
//  ShareView.swift
//  LinkClip
//
//  Created by 심관혁 on 3/11/25.
//

import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct ShareView: View {
    @State private var title: String = ""
    @State private var personalMemo: String = ""
    @State private var url: URL?
    @State private var selectedCategory: CategoryItem?

    // 저장완료 시 alert를 띄우기 위한 상태
    @State private var isSaved: Bool = false

    // Title
    var extensionTitle: String?

    // Extension Context를 전달받기 위한 프로퍼티
    var extensionContext: NSExtensionContext?

    // 카테고리 목록을 가져오기 위한 상태
    @State private var categories: [CategoryItem] = []

    // 이 뷰를 ShareExtension에서 사용할 수 있도록 초기화
    init(url: URL, extensionContext: NSExtensionContext?, extensionTitle: String?) {
        self._url = State(initialValue: url)
        self.extensionContext = extensionContext
        if extensionTitle != nil {
            // title이 존재하면 제목으로 설정
            self._title = State(initialValue: extensionTitle ?? "No title")
        } else {
            // URL의 호스트를 기본 제목으로 설정
            self._title = State(initialValue: url.host ?? "No title")
        }
    }

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(LocalizedStringResource("section_url_info", defaultValue: "URL 정보"))) {
                    Text(url?.absoluteString ?? "")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Section(header: Text(LocalizedStringResource("section_title", defaultValue: "제목"))) {
                    if #available(iOS 26, *) {
                        TextField(LocalizedStringResource("ph_url_title", defaultValue: "URL 제목"), text: $title)
                    } else {
                        TextField(String(localized: "ph_url_title"), text: $title)
                    }
                }

                Section(
                    header: Text(LocalizedStringResource("section_personal_memo", defaultValue: "개인 메모"))
                ) {
                    TextEditor(text: $personalMemo)
                        .frame(height: 100)
                }

                Section(header: Text(LocalizedStringResource("section_category", defaultValue: "카테고리"))) {
                    if categories.isEmpty {
                        Text(LocalizedStringResource("empty_categories", defaultValue: "카테고리가 없습니다."))
                            .foregroundColor(.secondary)
                            .italic()
                    } else {
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
                                    Text("\(parentName) > \(subCategory.name)").tag(subCategory as CategoryItem?)
                                }
                            }
                        }
                        .pickerStyle(.navigationLink)
                    }
                }
            }
            .navigationTitle(LocalizedStringResource("nav_save_url", defaultValue: "URL 저장"))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if #available(iOS 26, *) {
                        Button(LocalizedStringResource("btn_cancel", defaultValue: "취소")) {
                            if let extensionContext {
                                extensionContext.completeRequest(returningItems: [], completionHandler: nil)
                            } else {
                                dismiss()
                            }
                        }
                    } else {
                        Button(String(localized: "btn_cancel")) {
                            if let extensionContext {
                                extensionContext.completeRequest(returningItems: [], completionHandler: nil)
                            } else {
                                dismiss()
                            }
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if #available(iOS 26, *) {
                        Button(LocalizedStringResource("btn_save", defaultValue: "저장")) {
                            saveURL()
                        }
                    } else {
                        Button(String(localized: "btn_save")) {
                            saveURL()
                        }
                    }
                }
            }
            .alert(isPresented: $isSaved) {
                if #available(iOS 26, *) {
                    return Alert(
                        title: Text(LocalizedStringResource("alert_url_saved_title", defaultValue: "URL 저장됨")),
                        message: Text(
                            LocalizedStringResource(
                                "alert_url_saved_message", defaultValue: "URL이 성공적으로 저장되었습니다.")
                        ),
                        dismissButton: .default(
                            Text(LocalizedStringResource("btn_confirm", defaultValue: "확인")),
                            action: {
                                if let extensionContext {
                                    extensionContext.completeRequest(returningItems: [], completionHandler: nil)
                                } else {
                                    dismiss()
                                }
                            }
                        )
                    )
                } else {
                    return Alert(
                        title: Text(String(localized: "alert_url_saved_title")),
                        message: Text(String(localized: "alert_url_saved_message")),
                        dismissButton: .default(
                            Text(String(localized: "btn_confirm")),
                            action: {
                                if let extensionContext {
                                    extensionContext.completeRequest(returningItems: [], completionHandler: nil)
                                } else {
                                    dismiss()
                                }
                            }
                        )
                    )
                }
            }
            .onAppear {
                loadCategories()
            }
        }
    }

    func loadCategories() {
        let context = SharedModelContainer.shared.container.mainContext

        do {
            let descriptor = FetchDescriptor<CategoryItem>()
            categories = try context.fetch(descriptor)
        } catch {
            print("카테고리 로드 중 오류 발생: \(error)")
            categories = []
        }
    }

    private func saveURL() {
        guard let url = url else { return }

        let context = SharedModelContainer.shared.container.mainContext

        do {
            // 카테고리 ID를 사용하여 실제 카테고리 객체 가져오기
            var categoryToUse: CategoryItem? = nil
            if let selectedCategory = selectedCategory {
                let selectedCategoryID = selectedCategory.id
                let descriptor = FetchDescriptor<CategoryItem>(
                    predicate: #Predicate { $0.id == selectedCategoryID })
                if let foundCategory = try context.fetch(descriptor).first {
                    categoryToUse = foundCategory
                }
            }

            let urlString = url.absoluteString
            // 중복 URL 여부 확인 후 upsert 처리
            var existingDescriptor = FetchDescriptor<LinkItem>(
                predicate: #Predicate { $0.url == urlString }
            )
            existingDescriptor.fetchLimit = 1
            if let existing = try context.fetch(existingDescriptor).first {
                // 기존 항목 업데이트
                let newTitle = title.isEmpty ? (url.host ?? existing.title) : title
                existing.title = newTitle
                existing.personalMemo = personalMemo.isEmpty ? existing.personalMemo : personalMemo
                existing.category = categoryToUse
            } else {
                // 새 항목 삽입
                let savedURL = LinkItem(
                    url: urlString,
                    title: title.isEmpty ? (url.host ?? "제목 없음") : title,
                    personalMemo: personalMemo.isEmpty ? nil : personalMemo,
                    category: categoryToUse
                )
                context.insert(savedURL)
            }
            try context.save()

            isSaved = true
        } catch (let error) {
            print("URL 저장 중 오류 발생: \(error)")
            if error is ShareError {
                extensionContext?.cancelRequest(withError: error as! ShareError)
            } else {
                extensionContext?.cancelRequest(withError: ShareError.unknown)
            }
        }
    }
}

#Preview {
    ShareView(
        url: URL(string: "https://www.google.com")!, extensionContext: NSExtensionContext(),
        extensionTitle: nil)
}
