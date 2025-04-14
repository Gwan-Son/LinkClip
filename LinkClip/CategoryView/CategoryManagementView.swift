//
//  CategoryManagementView.swift
//  LinkToMe
//
//  Created by 심관혁 on 4/11/25.
//

import SwiftUI
import SwiftData

struct CategoryManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var categories: [CategoryItem]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            ForEach(categories) { category in
                HStack {
                    Image(systemName: category.icon)
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading) {
                        Text(category.name)
                            .font(.headline)
                        
                        if let parentCategory = category.parentCategory {
                            Text("상위 카테고리: \(parentCategory.name)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .onDelete(perform: deleteCategories)
        }
        .navigationTitle("카테고리 관리")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func deleteCategories(at offsets: IndexSet) {
        for index in offsets {
            let category = categories[index]
            modelContext.delete(category)
        }
        try? modelContext.save()
    }
}

#Preview {
    CategoryManagementView()
}
