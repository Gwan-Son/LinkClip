//
//  NothingView.swift
//  LinkClip
//
//  Created by 심관혁 on 4/8/25.
//

import SwiftUI

struct NothingView: View {
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "link.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundColor(.gray)

            Text(LocalizedStringResource("empty_saved_urls", defaultValue: "저장된 URL이 없습니다"))
                .font(.title2)
                .fontWeight(.medium)

            Text(
                LocalizedStringResource("guide_save_from_share", defaultValue: "웹에서 공유 버튼을 눌러 URL을 저장해보세요.")
            )
            .font(.body)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)

            Button(action: onTap) {
                Text(LocalizedStringResource("btn_onboarding_replay", defaultValue: "온보딩 다시보기"))
            }
            .padding(.top, 16)
        }
    }
}

#Preview {
    NothingView(onTap: {})
}
