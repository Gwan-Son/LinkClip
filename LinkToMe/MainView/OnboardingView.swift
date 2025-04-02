//
//  OnboardingView.swift
//  LinkToMe
//
//  Created by 심관혁 on 4/1/25.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0
    
    // 온보딩 페이지 데이터
    private let pages = [
        (image: "link.circle.fill", title: "URL 저장하기", description: "웹에서 흥미로운 컨텐츠를 발견하면 공유 버튼을 통해 바로 저장하세요."),
        (image: "square.and.pencil", title: "메모 추가하기", description: "각 URL에 제목과 개인 메모를 추가하여 나중에 쉽게 찾을 수 있습니다."),
        (image: "square.and.arrow.up", title: "언제든지 공유하기", description: "저장한 URL을 친구들과 쉽게 공유할 수 있습니다.")
    ]
    
    var body: some View {
        VStack {
            HStack {
                ForEach(0..<pages.count, id: \.self) { index in
                    Circle()
                        .fill(currentPage == index ? Color.blue : Color.gray.opacity(0.4))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.top, 24)
            
            Spacer()
            
            // 현재 페이지 내용
            Image(systemName: pages[currentPage].image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .foregroundColor(.blue)
                .padding()
            
            Text(pages[currentPage].title)
                .font(.title)
                .fontWeight(.bold)
                .padding(.top)
            
            Text(pages[currentPage].description)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.top, 8)
            
            Spacer()
            
            // 버튼
            HStack {
                if currentPage > 0 {
                    Button("이전") {
                        withAnimation {
                            currentPage -= 1
                        }
                    }
                    .padding()
                }
                
                Spacer()
                
                if currentPage < pages.count - 1 {
                    Button("다음") {
                        withAnimation {
                            currentPage += 1
                        }
                    }
                    .fontWeight(.bold)
                    .padding()
                } else {
                    Button("시작하기") {
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .padding()
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
    }
}

#Preview {
    OnboardingView()
}
