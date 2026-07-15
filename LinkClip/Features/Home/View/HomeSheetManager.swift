//
//  HomeSheetManager.swift
//  LinkClip
//
//  Created by 심관혁 on 12/16/25.
//

import SwiftUI

struct HomeSheetView: View {
    let sheetType: HomeSheetType
    let viewModel: HomeViewModel
    let onCategorySave: (String, String, String) -> Void
    let onLinkSave: () -> Void

    var body: some View {
        switch sheetType {
        case .settings:
            SettingView()
        case .addCategory:
            AddCategoryView(
                categories: viewModel.categories,
                onSave: { name, icon, colorHex in
                    onCategorySave(name, icon, colorHex)
                },
                editingCategory: nil
            )
        case .categoryManagement:
            CategoryManagementView(
                onCategoryDeleted: { viewModel.deleteCategory($0) },
                onOrderChanged: { viewModel.refreshData() }
            )
        case .addLink:
            AddLinkView(onLinkAdded: onLinkSave)
        case .editLink(let link):
            LinkEditView(link: link) { updatedLink in
                viewModel.refreshDataIfNeeded()
            }
        case .summary(let link):
            LinkSummaryView(link: link)
        }
    }
}
