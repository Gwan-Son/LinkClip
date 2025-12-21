//
//  HomeHeaderView.swift
//  LinkClip
//
//  Created by 심관혁 on 12/16/25.
//

import SwiftUI

struct HomeHeaderView: View {
    let onCategoryManagementTap: () -> Void
    let onSettingsTap: () -> Void

    var body: some View {
        HStack {
            Text("LinkClip")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)

            Spacer()

            // 카테고리 관리 버튼
            Button(action: onCategoryManagementTap) {
                Image(systemName: "tag")
                    .font(.system(size: 20))
                    .foregroundColor(.black)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.white)
                            .overlay(
                                Circle()
                                    .stroke(
                                        Color.black.opacity(0.05),
                                        lineWidth: 1
                                    )
                            )
                    )
            }

            // 설정 버튼
            Button(action: onSettingsTap) {
                Image(systemName: "gear")
                    .font(.system(size: 20))
                    .foregroundColor(.black)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.white)
                            .overlay(
                                Circle()
                                    .stroke(
                                        Color.black.opacity(0.05),
                                        lineWidth: 1
                                    )
                            )
                    )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 20)
        .background(Color.background)
    }
}
