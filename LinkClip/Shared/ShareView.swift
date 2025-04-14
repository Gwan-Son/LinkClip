//
//  ShareView.swift
//  LinkClip
//
//  Created by 심관혁 on 3/11/25.
//

import SwiftUI
import UniformTypeIdentifiers
import SwiftData

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
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("URL 정보")) {
                    Text(url?.absoluteString ?? "")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("제목")) {
                    TextField("URL 제목", text: $title)
                }
                
                Section(header: Text("개인 메모")) {
                    TextEditor(text: $personalMemo)
                        .frame(height: 100)
                }
                
                Section(header: Text("카테고리")) {
                    if categories.isEmpty {
                        Text("카테고리가 없습니다.")
                            .foregroundColor(.secondary)
                            .italic()
                    } else {
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
                        .pickerStyle(.navigationLink)
                    }
                }
            }
            .navigationTitle("URL 저장")
            .navigationBarItems(
                leading: Button("취소") {
                    // 취소 시 ExtensionContext 완료 처리
                    extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
                },
                trailing: Button("저장") {
                    saveURL()
                }
            )
            .alert(isPresented: $isSaved) {
                Alert(
                    title: Text("URL 저장됨"),
                    message: Text("URL이 성공적으로 저장되었습니다."),
                    dismissButton: .default(Text("확인"), action: {
                        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
                    })
                )
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
                let descriptor = FetchDescriptor<CategoryItem>(predicate: #Predicate{ $0.id == selectedCategoryID })
                if let foundCategory = try context.fetch(descriptor).first {
                    categoryToUse = foundCategory
                }
            }
            
            let savedURL = LinkItem(
                url: url.absoluteString,
                title: title.isEmpty ? (url.host ?? "제목 없음") : title,
                personalMemo: personalMemo.isEmpty ? nil : personalMemo,
                category: categoryToUse
            )
            
            context.insert(savedURL)
            try context.save()
            
            isSaved = true
        } catch(let error) {
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
    ShareView(url: URL(string: "https://www.google.com")!, extensionContext: NSExtensionContext(), extensionTitle: nil)
}
