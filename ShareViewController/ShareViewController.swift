//
//  ShareViewController.swift
//  ShareViewController
//
//  Created by 심관혁 on 2/18/25.
//

import UIKit
import SwiftUI
import SwiftData
import UniformTypeIdentifiers

// TODO: - UIKit에서 SwiftUI로 변경 - 완
// TODO: - 텍스트 추출 및 URL 추출 - 완
// TODO: - SwiftData로 메인 앱에 데이터 저장

class ShareViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isModalInPresentation = true
        
        if let extensionContext = extensionContext {
            let hostingView = UIHostingController(rootView: ShareView(extensionContext: extensionContext))
            hostingView.view.frame = view.frame
            view.addSubview(hostingView.view)
        }
        
    }

}

fileprivate struct ShareView: View {
    var extensionContext: NSExtensionContext?
    
    @State var titleText: String?
    @State var urlText: String?
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Link To Me")
                .font(.title3).bold()
                .frame(maxWidth: .infinity)
                .overlay(alignment: .leading) {
                    Button("취소", action: dismiss)
                        .tint(.red)
                }
                .overlay(alignment: .trailing) {
                    Button("저장", action: dismiss)
                        .tint(.blue)
                }
                .padding(.bottom, 10)
            Text(titleText ?? "No Item Selected")
                .font(.title)
                .lineLimit(0)
                .frame(maxWidth: .infinity, maxHeight: 50)
            Text(urlText ?? "No Item Selected")
                .font(.title2)
                .frame(maxWidth: .infinity, maxHeight: 50)
            
            Spacer(minLength: 0)
        }
        .padding(15)
        .onAppear {
            // 화면이 나타날 때 아이템 가져오기
            getItems()
        }
    }
    
    func getItems() {
        // Title
        guard let extensionItems = extensionContext?.inputItems as? [NSExtensionItem] else { return }
        guard let extensionItem = extensionItems.first else { return }
        titleText = extensionItem.attributedContentText?.string
        
        // URL
        guard let extensionItemProvider = extensionItem.attachments?.first else { return }
        
        if extensionItemProvider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
            extensionItemProvider.loadItem(forTypeIdentifier: UTType.url.identifier) { (url, error) in
                if let url = url as? URL {
                    DispatchQueue.main.async {
                        urlText = url.absoluteString
                    }
                } else {
                    print("Error loading URL: \(error?.localizedDescription ?? "")")
                }
            }
        }
    }
    
    func saveItems() {
        // SwiftData로 저장
        print("Save!!")
    }
    
    func dismiss() {
        extensionContext?.completeRequest(returningItems: [])
    }
}
