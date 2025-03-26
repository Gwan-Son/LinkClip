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
    
    var body: some View {
        NavigationStack {
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
            .navigationTitle("Links")
            .sheet(item: $selectedURLForEditing) { item in
                EditView(savedURL: item)
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
