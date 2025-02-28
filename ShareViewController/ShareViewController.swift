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

class ShareViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isModalInPresentation = true
        
        if let itemProviders = (extensionContext!.inputItems.first as? NSExtensionItem)?.attachments {
            let hostingView = UIHostingController(rootView: ShareView(itemProvider: itemProviders, extenstionContext: extensionContext))
            hostingView.view.frame = view.frame
            view.addSubview(hostingView.view)
        }
        
    }

}

fileprivate struct ShareView: View {
    var itemProvider: [NSItemProvider]
    var extenstionContext: NSExtensionContext?
    
    @State private var items: [Item] = []
    var body: some View {
        VStack(spacing: 15) {
            Text("Add to Link")
                .font(.title3.bold())
                .frame(maxWidth: .infinity)
                .overlay(alignment: .leading) {
                    Button("Cancel", action: dismiss)
                        .tint(.red)
                }
                .padding(.bottom, 10)
            
            Button(action: saveItems) {
                Text("Save")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.vertical, 10)
                    .foregroundColor(.white)
                    .background(.blue, in: .rect(cornerRadius: 10))
                    .contentShape(.rect)
            }
            
            Spacer(minLength: 0)
        }
        .padding(15)
        .onAppear {
            extractURL()
        }
        
    }
    
    func saveItems() {
        print("Save!!")
        do {
            let context = try ModelContext(.init(for: LinkItem.self))
            print(items)
            for item in items {
                context.insert(LinkItem(url: item.url))
                print(item.url)
            }
            
            try context.save()
            dismiss()
        } catch {
            print(error.localizedDescription)
            dismiss()
        }
    }
    
    func extractURL() {
        guard items.isEmpty else { return }
        DispatchQueue.global(qos: .userInteractive).async{
            for provider in itemProvider {
                let _ = provider.loadDataRepresentation(for: .url) { data, error in
                    if let data, let url = URL(dataRepresentation: data, relativeTo: nil) {
                        DispatchQueue.main.async {
                            items.append(.init(url: url))
                            // DEBUG
                            print("URL")
                            print(url)
                            print(type(of: url))
                            print("DATA")
                            print(data)
                            print(type(of: data))
                        }
                    }
                }
            }
        }
    }
    
    func dismiss() {
        extenstionContext?.completeRequest(returningItems: [])
    }
    
    private struct Item: Identifiable {
        let id: UUID = .init()
        var url: URL
//        var title: String
    }
}
