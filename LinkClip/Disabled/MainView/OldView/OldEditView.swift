////
////  EditView.swift
////  LinkClip
////
////  Created by 심관혁 on 3/26/25.
////
//
//import SwiftData
//import SwiftUI
//
//struct EditView: View {
//    @Bindable var savedURL: LinkItem
//    @Environment(\.dismiss) private var dismiss
//    @Environment(\.modelContext) private var modelContext
//
//    @Query(sort: \CategoryItem.createdDate, order: .forward) private var categories: [CategoryItem]
//    @State private var selectedCategories: Set<CategoryItem> = []
//
//    // personalMemo의 non-optional 버전을 위한 상태
//    @State private var memoText: String
//
//    init(savedURL: LinkItem) {
//        self._savedURL = Bindable(savedURL)
//        // 초기값 설정, nil이면 빈 문자열로 초기화
//        self._memoText = State(initialValue: savedURL.personalMemo ?? "")
//    }
//
//    var body: some View {
//        NavigationView {
//            Form {
//                Section(header: Text(LocalizedStringResource("section_url_info", defaultValue: "URL 정보"))) {
//                    Text(savedURL.url)
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                }
//                Section(header: Text(LocalizedStringResource("section_title", defaultValue: "제목"))) {
//                    if #available(iOS 26.0, *) {
//                        TextField(
//                            LocalizedStringResource("ph_url_title", defaultValue: "URL 제목"), text: $savedURL.title
//                        )
//                    } else {
//                        TextField(String(localized: "ph_url_title"), text: $savedURL.title)
//                    }
//                }
//
//                Section(
//                    header: Text(LocalizedStringResource("section_personal_memo", defaultValue: "개인 메모"))
//                ) {
//                    TextEditor(text: $memoText)
//                        .frame(height: 100)
//                }
//
//                Section(header: Text(LocalizedStringResource("section_category", defaultValue: "카테고리 (여러 개 선택 가능)"))) {
//                    if categories.isEmpty {
//                        Text("등록된 카테고리가 없습니다")
//                            .foregroundColor(.secondary)
//                            .italic()
//                    } else {
//                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 12)], spacing: 12) {
//                            ForEach(categories) { category in
//                                let color = Color(hex: category.safeColor)
//                                let isSelected = selectedCategories.contains(category)
//
//                                CategoryChip(
//                                    title: category.name,
//                                    icon: category.icon,
//                                    color: color,
//                                    isSelected: isSelected
//                                ) {
//                                    if isSelected {
//                                        selectedCategories.remove(category)
//                                    } else {
//                                        selectedCategories.insert(category)
//                                    }
//                                }
//                            }
//                        }
//                        .padding(.vertical, 8)
//                        .onAppear {
//                            // 초기 선택 상태 설정
//                            if let existingCategories = savedURL.categories {
//                                selectedCategories = Set(existingCategories)
//                            } else {
//                                selectedCategories = []
//                            }
//                        }
//                    }
//                }
//            }
//            .navigationTitle(LocalizedStringResource("nav_edit_url", defaultValue: "URL 편집"))
//            .navigationBarTitleDisplayMode(.inline)
//            .navigationBarItems(
//                leading: Button(LocalizedStringResource("btn_cancel", defaultValue: "취소")) {
//                    dismiss()
//                },
//                trailing: Button(LocalizedStringResource("btn_save", defaultValue: "저장")) {
//                    savedURL.personalMemo = memoText.isEmpty ? nil : memoText
//                    savedURL.categories = selectedCategories.isEmpty ? nil : Array(selectedCategories)
//                    try? modelContext.save()
//                    dismiss()
//                }
//            )
//        }
//    }
//}
//
//#Preview {
//    EditView(savedURL: LinkItem(url: "https://www.google.com", title: "구글"))
//}
