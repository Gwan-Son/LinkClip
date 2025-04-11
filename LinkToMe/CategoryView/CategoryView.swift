//
//  CategoryView.swift
//  LinkToMe
//
//  Created by 심관혁 on 4/11/25.
//

import SwiftUI
import SwiftData

struct CategoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var categories: [CategoryItem]
    @Query private var links: [LinkItem]
    
    @ObservedObject var viewModel: MainViewModel
    @State private var showAddCategory: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                // 카테고리가 없을 경우 안내 메시지
                if categories.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "folder.badge.plus")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .foregroundColor(.blue)
                        
                        Text("카테고리가 없습니다")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Text("카테고리를 추가하여 URL을 체계적으로 관리해보세요.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        
                        Button(action: {
                            showAddCategory = true
                        }) {
                            Text("카테고리 추가하기")
                                .fontWeight(.medium)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.top, 10)
                    }
                    .padding()
                } else {
                    // 카테고리 목록 표시
                    List {
                        // 미분류 항목
                        Section(header: HStack {
                            Image(systemName: "tray")
                            Text("미분류")
                        }) {
                            let uncategorizedLinks = links.filter {
                                $0.category == nil
                            }
                            
                            if uncategorizedLinks.isEmpty {
                                Text("항목 없음")
                                    .foregroundColor(.secondary)
                                    .italic()
                            } else {
                                ForEach(uncategorizedLinks) { link in
                                    LinkRowView(
                                        link: link,
                                        onTap: {
                                            viewModel.openURL(link.url)
                                        }, onCopy: {
                                            viewModel.copyURL(link.url)
                                        }, onEdit: {
                                            viewModel.selectedURLForEditing = link
                                        }, onDelete: {
                                            viewModel.deleteLink(link)
                                        })
                                }
                            }
                        }
                        
                        // 각 카테고리별 섹션
                        ForEach(
                            categories.filter { $0.parentCategory == nil
                            }) { category in
                                Section(header: HStack {
                                    Image(systemName: category.icon)
                                    Text(category.name)
                                }) {
                                    // 현재 카테고리에 속한 링크 표시
                                    let categoryLinks = links.filter {
                                        $0.category?.id == category.id
                                    }
                                
                                    if categoryLinks.isEmpty {
                                        Text("항목 없음")
                                            .foregroundColor(.secondary)
                                            .italic()
                                    } else {
                                        ForEach(categoryLinks) { link in
                                            LinkRowView(
                                                link: link,
                                                onTap: {
                                                    viewModel.openURL(link.url)
                                                }, onCopy: {
                                                    viewModel.copyURL(link.url)
                                                }, onEdit: {
                                                    viewModel.selectedURLForEditing = link
                                                }, onDelete: {
                                                    viewModel.deleteLink(link)
                                                })
                                        }
                                    }
                                
                                    // 하위 카테고리가 있는 경우 표시
                                    if let subCategories = category.subCategories, !subCategories.isEmpty {
                                        ForEach(subCategories) { subCategory in
                                            DisclosureGroup(
                                                content: {
                                                    let subCategoryLinks = links.filter {
                                                        $0.category?.id == subCategory.id
                                                    }
                                                
                                                    if subCategoryLinks.isEmpty {
                                                        Text("항목 없음")
                                                            .foregroundColor(
                                                                .secondary
                                                            )
                                                            .italic()
                                                    } else {
                                                        ForEach(
                                                            subCategoryLinks
                                                        ) { link in
                                                            LinkRowView(
                                                                link: link,
                                                                onTap: {
                                                                    viewModel
                                                                        .openURL(
                                                                            link.url
                                                                        )
                                                                },
                                                                onCopy: {
                                                                    viewModel
                                                                        .copyURL(
                                                                            link.url
                                                                        )
                                                                },
                                                                onEdit: {
                                                                    viewModel.selectedURLForEditing = link
                                                                },
                                                                onDelete: {
                                                                    viewModel
                                                                        .deleteLink(
                                                                            link
                                                                        )
                                                                })
                                                        }
                                                    }
                                                },
                                                label: {
                                                    HStack {
                                                        Image(
                                                            systemName: subCategory.icon
                                                        )
                                                        .foregroundColor(.blue)
                                                        Text(subCategory.name)
                                                            .font(.headline)
                                                    }
                                                }
                                            )
                                        }
                                    }
                                }
                            }
                    }
                }
            }
            .navigationTitle("카테고리")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showAddCategory = true
                    }) {
                        Label("카테고리 추가", systemImage: "folder.badge.plus")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: CategoryManagementView()) {
                        Label("카테고리 관리", systemImage: "gear")
                    }
                }
            }
            .sheet(isPresented: $showAddCategory) {
                AddCategoryView(
                    categories: categories,
                    onSave: {
 name,
                        icon,
                        parentCategory in
                        addCategory(
                            name: name,
                            icon: icon,
                            parentCategory: parentCategory
                        )
                    }
                )
            }
            .sheet(item: $viewModel.selectedURLForEditing) { item in
                EditView(savedURL: item)
            }
            .onAppear {
                viewModel.modelContext = modelContext
            }
        }
    }
    
    private func addCategory(
        name: String,
        icon: String,
        parentCategory: CategoryItem?
    ) {
        let newCategory = CategoryItem(
            name: name,
            icon: icon,
            parentCategory: parentCategory
        )
        modelContext.insert(newCategory)
        try? modelContext.save()
    }
}

#Preview {
    CategoryView(viewModel: MainViewModel())
}
