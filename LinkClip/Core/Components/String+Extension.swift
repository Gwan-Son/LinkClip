//
//  String+Extension.swift
//  LinkClip
//
//  Created by 심관혁 on 6/5/25.
//

import Foundation
import SwiftUI

extension String {
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
}

extension Notification.Name {
    static let openLinkFromSpotlight = Notification.Name("openLinkFromSpotlight")
}
