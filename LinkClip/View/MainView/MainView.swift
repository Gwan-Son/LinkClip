//
//  viewController.swift
//  LinkClip
//
//  Created by 심관혁 on 2/18/25.
//

import SwiftData
import SwiftUI

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
                                },
                                onCopy: {
                                    viewModel.copyURL(link.url)
                                },
                                onEdit: {
                                    viewModel.selectedURLForEditing = link
                                },
                                onDelete: {
                                    Task { await viewModel.deleteLink(link) }
                                })
                        }
                    }
                }
            }
            .navigationTitle(LocalizedStringResource("nav_saved_urls", defaultValue: "저장된 URL"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Picker(
                            LocalizedStringResource("sort_options", defaultValue: "정렬 옵션"),
                            selection: $viewModel.sortOption
                        ) {
                            ForEach(SortOption.allCases) { option in
                                Text(option.displayName).tag(option)
                            }
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
            .searchable(
                text: $viewModel.searchText,
                prompt: LocalizedStringResource("search_prompt", defaultValue: "URL 또는 제목 검색")
            )
            .searchScopes(
                $viewModel.searchScope,
                scopes: {
                    ForEach(SearchScope.allCases, id: \.self) { scope in
                        Text(scope.displayName).tag(scope)
                    }
                }
            )
            .fullScreenCover(
                isPresented: $viewModel.showOnboarding,
                content: {
                    OnboardingView()
                }
            )
            .sheet(
                isPresented: $viewModel.showSetting,
                content: {
                    SettingView()
                }
            )
            .task {
                // ModelContext에 뷰모델 단발 주입 및 온보딩 체크
                viewModel.setContextIfNeeded(modelContext)
                viewModel.checkOnboarding()
            }
            .toast(isShowing: $viewModel.showToast, message: viewModel.toastMessage)
        }
    }
}

#Preview {
    MainView(viewModel: MainViewModel())
}
