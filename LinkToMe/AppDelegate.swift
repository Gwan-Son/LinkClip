//
//  AppDelegate.swift
//  LinkToMe
//
//  Created by 심관혁 on 2/25/25.
//

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        setupNotificationObserver()
        return true
    }
    
    private func setupNotificationObserver() {
        let userDefaults = UserDefaults(suiteName: "group.kr.gwanson.LinkToMe")
        userDefaults?.addObserver(self, forKeyPath: "newLinkAdded",options: .new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "newLinkAdded" {
            NotificationCenter.default.post(name: NSNotification.Name("NewLinkAdded"), object: nil)
            UserDefaults(suiteName: "group.kr.gwanson.LinkToMe")?.removeObject(forKey: "newLinkAdded")
        }
    }
}
