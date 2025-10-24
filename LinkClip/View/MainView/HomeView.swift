//
//  HomeView.swift
//  LinkClip
//
//  Created by 심관혁 on 4/11/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @StateObject private var viewModel = MainViewModel()
    
    var body: some View {
        TabView {
            MainView(viewModel: viewModel)
                .tabItem {
                    Label("URL 목록", systemImage: "link")
                }

            CategoryView(viewModel: viewModel)
                .tabItem {
                    Label("카테고리", systemImage: "folder")
                }
        }
        .tint(.main)
    }
}

#Preview {
    HomeView()
}
