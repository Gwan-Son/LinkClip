//
//  viewController.swift
//  LinkToMe
//
//  Created by 심관혁 on 2/18/25.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LinkItem.savedDate, order: .reverse)
    private var links: [LinkItem]
    
    // ViewModel 추가
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        NavigationStack {
            Group {
                // 필터링 및 정렬된 링크 계산
                let processedLinks = viewModel.sortLinks(viewModel.filterLinks(links))
                
                if processedLinks.isEmpty {
                    NothingView(onTap: {
                        viewModel.showOnboarding = true
                    })
                    .padding()
                } else {
                    // 저장된 URL이 있을 때 리스트 표시
                    List {
                        ForEach(processedLinks) { link in
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
            }
            .navigationTitle("저장된 URL")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Picker("정렬 옵션", selection: $viewModel.sortOption) {
                            Text("최신순").tag(SortOption.dateNewest)
                            Text("오래된순").tag(SortOption.dateOldest)
                            Text("제목 (A-Z)").tag(SortOption.titleAtoZ)
                            Text("제목 (Z-A)").tag(SortOption.titleZtoA)
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down.circle")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showSetting = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "URL 또는 제목 검색")
            .searchScopes($viewModel.searchScope, scopes: {
                ForEach(SearchScope.allCases, id: \.self) { scope in
                    Text(scope.rawValue).tag(scope)
                }
            })
            .sheet(item: $viewModel.selectedURLForEditing) { item in
                EditView(savedURL: item)
            }
            .sheet(isPresented: $viewModel.showOnboarding) {
                OnboardingView()
            }
            .sheet(isPresented: $viewModel.showSetting, content: {
                SettingView()
            })
            .onAppear {
                // ModelContext에 뷰모델 주입
                viewModel.modelContext = modelContext
                viewModel.checkOnboarding()
            }
            .toast(isShowing: $viewModel.showToast, message: viewModel.toastMessage)
        }
    }
}

#Preview {
    MainView(viewModel: MainViewModel())
}
