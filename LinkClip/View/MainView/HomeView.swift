//
//  HomeView.swift
//  LinkClip
//
//  Created by 심관혁 on 4/11/25.
//

import CoreSpotlight
import SwiftData
import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = MainViewModel()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        TabView {
            MainView(viewModel: viewModel)
                .tabItem {
                    Label(
                        LocalizedStringResource("tab_url_list", defaultValue: "URL 목록"), systemImage: "link")
                }

            CategoryView(viewModel: viewModel)
                .tabItem {
                    Label(
                        LocalizedStringResource("tab_category", defaultValue: "카테고리"), systemImage: "folder")
                }
        }
        .tint(.main)
        .onContinueUserActivity(CSSearchableItemActionType) { activity in
            guard let idString = activity.userInfo?[CSSearchableItemActivityIdentifier] as? String,
                  let linkId = UUID(uuidString: idString)
            else { return }
            openLink(withId: linkId)
        }
        .onReceive(NotificationCenter.default.publisher(for: .openLinkFromSpotlight)) { note in
            guard let linkId = note.object as? UUID else { return }
            openLink(withId: linkId)
        }
        .sheet(
            item: $viewModel.selectedURLForEditing,
            onDismiss: {
                // 선택 초기화로 재표시 중복 방지
                viewModel.selectedURLForEditing = nil
            }
        ) { item in
            EditView(savedURL: item)
        }
    }

    private func openLink(withId id: UUID) {
        let predicate = #Predicate<LinkItem> { $0.id == id }
        var descriptor = FetchDescriptor<LinkItem>(predicate: predicate)
        descriptor.fetchLimit = 1
        if let link = try? modelContext.fetch(descriptor).first {
            viewModel.openURL(link.url)
            Task { await SpotlightIndexingService().index(link: link) }
        }
    }
}

#Preview {
    HomeView()
}
