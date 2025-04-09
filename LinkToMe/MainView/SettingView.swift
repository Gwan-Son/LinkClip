//
//  SettingView.swift
//  LinkToMe
//
//  Created by 심관혁 on 4/8/25.
//

import SwiftUI
import SwiftData
import MessageUI

struct SettingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // 알림창 상태 관리
    @State private var showingResetAlert: Bool = false
    @State private var showingMailView: Bool = false
    @State private var mailResult: Result<MFMailComposeResult, Error>? = nil
    
    // 앱 정보
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    var body: some View {
        NavigationStack {
            List {
                // 앱 정보 섹션
                Section {
                    HStack {
                        Image(systemName: "link.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.blue)
                            .padding(.trailing, 10)
                        
                        VStack(alignment: .leading) {
                            Text("LinkToMe")
                                .font(.headline)
                            
                            Text("버전 \(appVersion) \(buildNumber)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // 데이터 관리 섹션
                Section(header: Text("데이터 관리")) {
                    Button(role: .destructive) {
                        showingResetAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                            Text("저장된 URL 초기화")
                        }
                    }
                }
                
                // 지원 섹션
                Section(header: Text("지원")) {
                    Button {
                        if MFMailComposeViewController.canSendMail() {
                            showingMailView = true
                        } else {
                            UIPasteboard.general.string = "example@example.com"
                        }
                    } label: {
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(.blue)
                            Text("문의하기")
                            
                            Spacer()
                            
                            if !MFMailComposeViewController.canSendMail() {
                                Text("이메일 주소 복사")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Link(destination: URL(string: "https://example.com")!) {
                        HStack {
                            Image(systemName: "hand.raised")
                                .foregroundColor(.blue)
                            Text("개인정보 처리방침")
                            Spacer()
                            Image(systemName: "arrow.and.right.square")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Link(destination: URL(string: "https://example.com")!) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.blue)
                            Text("이용약관")
                            Spacer()
                            Image(systemName: "arrow.and.right.square")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        
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
