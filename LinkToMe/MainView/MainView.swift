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
    
    // 현재 편집 중인 URL을 추적하기 위한 상태
    @State private var selectedURLForEditing: LinkItem?
    
    // 온보딩 표시 여부 상태
    @State private var showOnboarding: Bool = false
    
    // UserDefaults를 사용하여 앱이 처음 실행되었는지 확인
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    
    // 검색어를 저장할 상태 변수
    @State private var searchText: String = ""
    @State private var searchScope: SearchScope = .all
    
    // 정렬 옵션 상태
    @State private var sortOption: SortOption = .dateNewest
    
    var filteredLinks: [LinkItem] {
        if searchText.isEmpty {
            return links
        } else {
            return links.filter { link in
                switch searchScope {
                case .all:
                    return link.title.localizedCaseInsensitiveContains(searchText) || link.url.localizedCaseInsensitiveContains(searchText) || (link.personalMemo ?? "").localizedCaseInsensitiveContains(searchText)
                case .title:
                    return link.title.localizedCaseInsensitiveContains(searchText)
                case .url:
                    return link.url.localizedCaseInsensitiveContains(searchText)
                case .memo:
                    return (link.personalMemo ?? "").localizedCaseInsensitiveContains(searchText)
                }
                
            }
        }
    }
    
    var sortedLinks: [LinkItem] {
        let filtered = filteredLinks
        
        switch sortOption {
        case .dateNewest:
            return filtered.sorted { $0.savedDate > $1.savedDate }
        case .dateOldest:
            return filtered.sorted { $0.savedDate < $1.savedDate }
        case .titleAtoZ:
            return filtered.sorted { $0.title < $1.title }
        case .titleZtoA:
            return filtered.sorted { $0.title > $1.title }
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if filteredLinks.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "link.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray)
                        
                        Text("저장된 URL이 없습니다.")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Text("웹에서 공유 버튼을 눌러 URL을 저장해보세요.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        
                        Button("온보딩 다시보기") {
                            showOnboarding = true
                        }
                        .padding(.top, 16)
                    }
                    .padding()
                } else {
                    // 저장된 URL이 있을 때 리스트 표시
                    List {
                        ForEach(sortedLinks) { link in
                            LinkRowView(
                                link: link,
                                onTap: {
                                    if let url = URL(string: link.url) {
                                        UIApplication.shared.open(url)
                                    }
                                }, onEdit: {
                                    selectedURLForEditing = link
                                }, onDelete: {
                                    deleteLink(link)
                                })
                        }
                    }
                }
            }
            .navigationTitle("저장된 URL")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button("최신순") { sortOption = .dateNewest }
                        Button("오래된순") { sortOption = .dateOldest }
                        Button("제목 (A-Z)") { sortOption = .titleAtoZ }
                        Button("제목 (Z-A)") { sortOption = .titleZtoA }
                    } label: {
                        Label("정렬", systemImage: "arrow.up.arrow.down")
                    }
                }
            }
            .searchable(text: $searchText, prompt: "URL 또는 제목 검색")
            .searchScopes($searchScope, scopes: {
                ForEach(SearchScope.allCases, id: \.self) { scope in
                    Text(scope.rawValue).tag(scope)
                }
            })
            .sheet(item: $selectedURLForEditing) { item in
                EditView(savedURL: item)
            }
            .sheet(isPresented: $showOnboarding) {
                OnboardingView()
            }
            .onAppear {
                if !hasSeenOnboarding {
                    showOnboarding = true
                    hasSeenOnboarding = true
                }
            }
        }
    }
    
    private func deleteLink(_ link: LinkItem) {
        modelContext.delete(link)
    }
}

#Preview {
    MainView()
}
