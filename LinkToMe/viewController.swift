//
//  viewController.swift
//  LinkToMe
//
//  Created by 심관혁 on 2/18/25.
//

import SwiftUI
import SwiftData

struct viewController: View {
//    @Query(sort: \LinkItem.createdDate, order: .reverse) private var links: [LinkItem]
    @Query private var links: [LinkItem]
    @Environment(\.modelContext) private var context
    @State private var showingAddLink = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(links) { link in
                    LinkRow(link: link)
                        .swipeActions {
                            Button(role: .destructive) {
                                deleteLink(link)
                            } label: {
                                Label("삭제", systemImage: "trash")
                            }
                        }
                }
            }
            .navigationTitle("Links")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddLink.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddLink) {
                AddLinkView()
            }
        }
    }
    
    private func deleteLink(_ link: LinkItem) {
        context.delete(link)
    }
}

//#Preview {
//    let config = ModelConfiguration(isStoredInMemoryOnly: true)
//    let container = try! ModelContainer(for: LinkItem.self, configurations: config)
//    
//    for i in 1...10 {
//        let link = LinkItem(
//            url: URL(string: "https://www.dogdrip.net/61536450\(i)")!,
//            title: "Sample Link \(i)"
//        )
//        container.mainContext.insert(link)
//    }
//    
//    return viewController()
//        .modelContainer(container)
//}
