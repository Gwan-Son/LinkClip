//
//  AddCategoryView.swift
//  LinkToMe
//
//  Created by 심관혁 on 4/11/25.
//

import SwiftUI

struct AddCategoryView: View {
    let categories: [CategoryItem]
    let onSave: (String, String, CategoryItem?) -> Void
    
    @State private var categoryName: String = ""
    @State private var selectedIcon = "folder"
    @State private var selectedParentCategory: CategoryItem?
    @Environment(\.dismiss) private var dismiss
    
    let icons = ["folder", "tag", "bookmark", "link", "doc", "newspaper", "book",
                 "graduationcap", "briefcase", "cart", "creditcard", "heart",
                 "house", "car", "airplane", "gamecontroller", "tv", "music.note",
                 "photo", "person", "globe"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("카테고리 정보")) {
                    TextField("카테고리 이름", text: $categoryName)
                    
                    Picker("상위 카테고리", selection: $selectedParentCategory) {
                        Text("없음").tag(nil as CategoryItem?)
                        ForEach(categories.filter { $0.parentCategory == nil }) { category in
                            Text(category.name).tag(category as CategoryItem?)
                        }
                    }
                }
                
                Section(header: Text("아이콘 선택")) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))]) {
                        ForEach(icons, id: \.self) { icon in
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedIcon == icon ? Color.blue.opacity(0.2) : Color.clear)
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: icon)
                                    .font(.title2)
                                    .foregroundColor(selectedIcon == icon ? .blue : .primary)
                                    .frame(width: 50, height: 50)
                            }
                            .onTapGesture {
                                selectedIcon = icon
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("새 카테고리")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        if !categoryName.isEmpty {
                            onSave(categoryName, selectedIcon, selectedParentCategory)
                            dismiss()
                        }
                    }
                    .disabled(categoryName.isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddCategoryView(categories: [], onSave: { _, _, _ in })
}
