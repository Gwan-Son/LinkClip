//
//  SettingView.swift
//  LinkToMe
//
//  Created by 심관혁 on 4/8/25.
//

import SwiftUI
import SwiftData

struct SettingView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        VStack {
            Button("초기화", role: .destructive) {
                // 모든 Link 가져오기
                let fetchDescriptor = FetchDescriptor<LinkItem>()
                if let item = try? modelContext.fetch(fetchDescriptor) {
                    // 모든 항목 삭제
                    for item in item {
                        modelContext.delete(item)
                    }
                    
                    // 변경 사항 저장
                    try? modelContext.save()
                }
                // TODO: - Alert 추가하기.
                // TODO: - 보기 좋게 만들기.
            }
        }
    }
}

#Preview {
    SettingView()
}
