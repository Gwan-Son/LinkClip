//
//  ShareView.swift
//  LinkToMe
//
//  Created by 심관혁 on 3/11/25.
//

import SwiftUI
import UniformTypeIdentifiers
import SwiftData

struct ShareView: View {
    @State private var title: String = ""
    @State private var personalMemo: String = ""
    @State private var url: URL?
    
    // Extension Context를 전달받기 위한 프로퍼티
    var extensionContext: NSExtensionContext?
    
    // 이 뷰를 ShareExtension에서 사용할 수 있도록 초기화
    init(url: URL, extensionContext: NSExtensionContext?) {
        self._url = State(initialValue: url)
        self.extensionContext = extensionContext
        // URL의 호스트를 기본 제목으로 설정
        self._title = State(initialValue: url.host ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("URL 정보")) {
                    Text(url?.absoluteString ?? "")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("제목")) {
                    TextField("URL 제목", text: $title)
                }
                
                Section(header: Text("개인 메모")) {
                    TextEditor(text: $personalMemo)
                        .frame(height: 100)
                }
            }
            .navigationTitle("URL 저장")
            .navigationBarItems(
                leading: Button("취소") {
                    // 취소 시 ExtensionContext 완료 처리
                    extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
                },
                trailing: Button("저장") {
                    saveURL()
                    extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
                }
            )
        }
    }
    
    private func saveURL() {
        guard let url = url else { return }
        
        let container = createSharedModelContainer()
        
        do {
            let context = container.mainContext
            let savedURL = LinkItem(
                url: url.absoluteString,
                title: title.isEmpty ? (url.host ?? "제목 없음") : title,
                personalMemo: personalMemo.isEmpty ? nil : personalMemo
            )
            
            context.insert(savedURL)
            try context.save()
            
//            showSavedAlert(url: url)
        } catch(let error) {
            print("URL 저장 중 오류 발생: \(error)")
            if error is ShareError {
                extensionContext?.cancelRequest(withError: error as! ShareError)
            } else {
                extensionContext?.cancelRequest(withError: ShareError.unknown)
            }
        }
    }
    
    //TODO: - 저장 완료 시 Alert 띄우기
    private func showSavedAlert(url: URL) {
        let alert = UIAlertController(
            title: "URL 저장됨",
            message: "URL이 성공적으로 저장되었습니다.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
            self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
        })
        
//        self.present(alert, animated: true)
    }
}

#Preview {
    ShareView(url: URL(string: "https://www.google.com")!, extensionContext: NSExtensionContext())
}
