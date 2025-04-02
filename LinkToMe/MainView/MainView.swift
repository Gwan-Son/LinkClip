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
    @State private var showOnboarding = false
    
    // UserDefaults를 사용하여 앱이 처음 실행되었는지 확인
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    var body: some View {
        NavigationStack {
            Group {
                if links.isEmpty {
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
                        ForEach(links) { link in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(link.title)
                                    .font(.headline)
                                
                                Text(link.url)
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                
                                if let memo = link.personalMemo, !memo.isEmpty {
                                    Text(memo)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.top, 4)
                                }
                            }
                            .swipeActions(content: {
                                Button(role: .destructive) {
                                    deleteLink(link)
                                } label: {
                                    Label("삭제", systemImage: "trash")
                                }
                                
                                Button {
                                    selectedURLForEditing = link
                                } label: {
                                    Label("수정", systemImage: "pencil")
                                }
                            })
                            // 저장된 URL 터치 시 해당 URL로 이동 - safari
                            .onTapGesture {
                                if let url = URL(string: link.url) {
                                    UIApplication.shared.open(url)
                                }
                            }
                            .contextMenu {
                                // 해당 URL이 정상적이면 공유 기능 활성화
                                if let url = URL(string: link.url) {
                                    ShareLink(item: url) {
                                        Label("공유", systemImage: "square.and.arrow.up")
                                    }
                                }
                                
                                Button {
                                    selectedURLForEditing = link
                                } label: {
                                    Label("수정", systemImage: "pencil")
                                }
                                
                                Button(role: .destructive) {
                                    modelContext.delete(link)
                                    try? modelContext.save()
                                } label: {
                                    Label("삭제", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("저장된 URL")
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
