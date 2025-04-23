//
//  SettingView.swift
//  LinkClip
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
    
    // 토스트 메시지 상태
    @State private var showingToast: Bool = false
    @State private var toastMessage: String = ""
    
    // 앱 정보
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    var body: some View {
        NavigationStack {
            List {
                // 앱 정보 섹션
                Section {
                    HStack {
                        Image(.setting)
                            .resizable()
                            .cornerRadius(20)
                            .frame(width: 50, height: 50)
                            .foregroundColor(.blue)
                            .padding(.trailing, 10)

                        VStack(alignment: .leading) {
                            Text("LinkClip")
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
                            // 메일을 보낼 수 없는 경우 클립보드에 이메일 주소 복사
                            UIPasteboard.general.string = "id1593572580@gmail.com"
                            
                            // 토스트 메시지 표시
                            toastMessage = "이메일 주소가 복사되었습니다."
                            withAnimation {
                                showingToast = true
                            }
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
                    
                    Link(destination: URL(string: "https://raw.githubusercontent.com/Gwan-Son/LinkToMe/refs/heads/main/privacy/privacy.md?token=GHSAT0AAAAAADBEVSW3NJUWO3XXIY7PK4342AILEVQ")!) {
                        HStack {
                            Image(systemName: "hand.raised")
                                .foregroundColor(.blue)
                            Text("개인정보 처리방침")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Link(destination: URL(string: "https://raw.githubusercontent.com/Gwan-Son/LinkToMe/refs/heads/main/privacy/service.md?token=GHSAT0AAAAAADBEVSW2G4DHQIRIQUYAFFHE2AILFEA")!) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.blue)
                            Text("이용약관")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // 앱 정보 섹션
                // TODO: - 앱 등록되면 정보탭 추가
                Section(header: Text("정보")) {
                    Link(destination: URL(string: "https://apps.apple.com/app/id")!) {
                        HStack {
                            Image(systemName: "star")
                                .foregroundColor(.yellow)
                            Text("앱 평가하기")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // 푸터 정보
                Section {
                    Text("@ 2025 Linkclip. All rights reserved.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowBackground(Color.clear)
                }
            }
            .tint(.blue)
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("완료") {
                        dismiss()
                    }
                }
            }
            .alert("모든 URL을 삭제하시겠습니까?", isPresented: $showingResetAlert) {
                Button("취소", role: .cancel) { }
                Button("삭제", role: .destructive) {
                    resetAllData()
                }
            } message: {
                Text("이 작업은 되돌릴 수 없습니다.")
            }
            .sheet(isPresented: $showingMailView) {
                MailView(result: $mailResult, subjects: "LinkClip 앱 문의", messageBody: "앱 버전: \(appVersion)")
            }
            .toast(isShowing: $showingToast, message: toastMessage)
        }
    }
    
    private func resetAllData() {
        do {
            let fetchDescriptor = FetchDescriptor<LinkItem>()
            let items = try modelContext.fetch(fetchDescriptor)
            
            for item in items {
                modelContext.delete(item)
            }
            
            try modelContext.save()
            
            // 초기화 완료 토스트 메시지
            toastMessage = "모든 URL이 초기화되었습니다."
            withAnimation {
                showingToast = true
            }
        } catch {
            print("데이터 초기화 중 오류 발생: \(error.localizedDescription)")
        }
    }
}

#Preview {
    SettingView()
}
