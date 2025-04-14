//
//  EditView.swift
//  LinkClip
//
//  Created by 심관혁 on 3/26/25.
//

import SwiftUI
import SwiftData

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
                Section(header: Text("URL 정보")) {
                    Text(savedURL.url)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Section(header: Text("제목")) {
                    TextField("URL 제목", text: $savedURL.title)
                }
                
                Section(header: Text("개인 메모")) {
                    TextEditor(text: $memoText)
                        .frame(height: 100)
                }
                
                Section(header: Text("카테고리")) {
                    Picker("카테고리 선택", selection: $selectedCategory) {
                        Text("없음").tag(nil as CategoryItem?)
                        
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
                    .onChange(of: selectedCategory) { _, newValue in
                        savedURL.category = newValue
                    }
                    .onAppear {
                        selectedCategory = savedURL.category
                    }
                }
            }
            .navigationTitle("URL 편집")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("취소") {
                    dismiss()
                },
                trailing: Button("저장") {
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
