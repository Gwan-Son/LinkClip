//
//  HomeView.swift
//  LinkClip
//
//  Created by 심관혁 on 4/11/25.
//

import SwiftData
import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = MainViewModel()

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
}

#Preview {
    HomeView()
}
