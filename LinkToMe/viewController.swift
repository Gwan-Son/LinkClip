//
//  viewController.swift
//  LinkToMe
//
//  Created by 심관혁 on 2/18/25.
//

import SwiftUI
import SwiftData

struct viewController: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LinkItem.savedDate, order: .reverse)
    private var links: [LinkItem]
    @State private var showingAddLink = false
    
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
                    })
                    //TODO: - contextMenu에 수정, 공유 기능 추가
                    .contextMenu {
                        Button {
                            if let url = URL(string: link.url) {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            Label("열기", systemImage: "safari")
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
            .sheet(isPresented: $showingAddLink) {
                AddLinkView()
            }
        }
    }
    
    private func deleteLink(_ link: LinkItem) {
        modelContext.delete(link)
    }
}

#Preview {
    viewController()
}
