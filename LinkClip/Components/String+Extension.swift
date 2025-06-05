//
//  String+Extension.swift
//  LinkClip
//
//  Created by 심관혁 on 6/5/25.
//

import SwiftUI

extension String {
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
}
