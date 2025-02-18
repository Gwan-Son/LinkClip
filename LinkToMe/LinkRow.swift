//
//  LinkRow.swift
//  LinkToMe
//
//  Created by 심관혁 on 2/18/25.
//

import SwiftUI

struct LinkRow: View {
    let link: LinkItem
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(link.title)
                    .font(.headline)
                Text(link.url.host ?? "")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            AsyncImage(url: link.url) { image in
                image.resizable().scaledToFit().frame(width: 60)
            } placeholder: {
                ProgressView()
            }
        }
    }
}

//#Preview {
//    LinkRow()
//}
