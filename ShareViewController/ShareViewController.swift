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

// TODO: - UIKit에서 SwiftUI로 변경
// TODO: - 텍스트 추출 및 URL 추출
// TODO: - SwiftData로 메인 앱에 데이터 저장

class ShareViewController: UIViewController {
    private var navigationBar: UINavigationBar!
    private var itemLabel: UILabel!
    private var itemText: String?
    
    override func loadView() {
        super.loadView()
        guard let extensionContext = extensionContext else { return }
        guard let extensionItems = extensionContext.inputItems as? [NSExtensionItem] else { return }
        guard let extensionItem = extensionItems.first else { return }
        
        itemText = extensionItem.attributedContentText?.string
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        itemLabel.text = itemText
        
//        isModalInPresentation = true
//        
//        if let itemProviders = (extensionContext!.inputItems.first as? NSExtensionItem)?.attachments {
//            let hostingView = UIHostingController(rootView: ShareView(itemProvider: itemProviders, extenstionContext: extensionContext))
//            hostingView.view.frame = view.frame
//            view.addSubview(hostingView.view)
//        }
        
    }

}

extension ShareViewController {
    private func configureView() {
        view.backgroundColor = .systemBackground
        configureNavigationBar()
        configureItemLabel()
    }
    
    private func configureNavigationBar() {
        navigationBar = UINavigationBar()
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        
        let navItem = UINavigationItem(title: "Share")
        navItem.leftBarButtonItem = UIBarButtonItem(systemItem: .cancel)
        navItem.rightBarButtonItem = UIBarButtonItem(systemItem: .done)
        navigationBar.setItems([navItem], animated: false)
        
        view.addSubview(navigationBar)
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    private func configureItemLabel() {
        itemLabel = UILabel()
        itemLabel.translatesAutoresizingMaskIntoConstraints = false
        itemLabel.backgroundColor = .black
        itemLabel.textColor = .white
        itemLabel.text = "No Item Selected"
        
        view.addSubview(itemLabel)
        
        NSLayoutConstraint.activate([
            itemLabel.widthAnchor.constraint(equalToConstant: 300),
            itemLabel.heightAnchor.constraint(equalToConstant: 50),
            itemLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            itemLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

//fileprivate struct ShareView: View {
//    var itemProvider: [NSItemProvider]
//    var extenstionContext: NSExtensionContext?
//    
//    @State private var items: [Item] = []
//    var body: some View {
//        VStack(spacing: 15) {
//            Text("Add to Link")
//                .font(.title3.bold())
//                .frame(maxWidth: .infinity)
//                .overlay(alignment: .leading) {
//                    Button("Cancel", action: dismiss)
//                        .tint(.red)
//                }
//                .padding(.bottom, 10)
//            
//            Button(action: saveItems) {
//                Text("Save")
//                    .font(.title3)
//                    .fontWeight(.semibold)
//                    .padding(.vertical, 10)
//                    .foregroundColor(.white)
//                    .background(.blue, in: .rect(cornerRadius: 10))
//                    .contentShape(.rect)
//            }
//            
//            Spacer(minLength: 0)
//        }
//        .padding(15)
//        .onAppear {
//            extractURL()
//        }
//        
//    }
//    
//    func saveItems() {
//        print("Save!!")
//        do {
//            let context = try ModelContext(.init(for: LinkItem.self))
//            print(items)
//            for item in items {
//                context.insert(LinkItem(url: item.url))
//                print(item.url)
//            }
//            
//            try context.save()
//            dismiss()
//        } catch {
//            print(error.localizedDescription)
//            dismiss()
//        }
//    }
//    
//    func extractURL() {
//        guard items.isEmpty else { return }
//        if let item = extenstionContext?.inputItems.first as? NSExtensionItem,
//           let itemProviders = item.attachments {
//            itemProviders.forEach { itemProvider in
//                if itemProvider.hasItemConformingToTypeIdentifier("public.url") {
//                    itemProvider.loadItem(forTypeIdentifier: "public.url") { (url, error) in
//                        if let sharedURL = url as? URL {
//                            // Save the URL to your database
//                            print("가져온 URL: \(sharedURL)")
//                        } else {
//                            print("Error loading URL: \(error?.localizedDescription ?? "")")
//                        }
//                    }
//                }
//            }
//        }
//    }
//    
//    func dismiss() {
//        extenstionContext?.completeRequest(returningItems: [])
//    }
//    
//    private struct Item: Identifiable {
//        let id: UUID = .init()
//        var url: URL
////        var title: String
//    }
//}
