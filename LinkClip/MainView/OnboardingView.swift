//
//  OnboardingView.swift
//  LinkClip
//
//  Created by 심관혁 on 4/1/25.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0
    
    // 애니메이션 상태 변수
    @State private var isAnimating: Bool = false
    @Namespace private var namespace
    
    // 온보딩 페이지 데이터
    private let pages = [
        (image: "link.circle.fill", title: "URL 저장하기", description: "웹에서 흥미로운 컨텐츠를 발견하면 공유 버튼을 통해 바로 저장하세요."),
        (image: "square.and.pencil.circle.fill", title: "메모 추가하기", description: "각 URL에 제목과 개인 메모를 추가하여 나중에 쉽게 찾을 수 있습니다."),
        (image: "square.and.arrow.up.circle.fill", title: "언제든지 공유하기", description: "저장한 URL을 친구들과 쉽게 공유할 수 있습니다.")
    ]

    var body: some View {
        ZStack {
            // 배경 그라데이션
            LinearGradient(
                gradient: Gradient(colors: [Color.white, Color.background.opacity(0.1)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                // 페이지 인디케이터
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule()
                            .fill(currentPage == index ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: currentPage == index ? 20 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.top, 20)
                
                // 페이지 컨텐츠
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        VStack(spacing: 30) {
                            Spacer()
                            
                            // 아이콘
                            ZStack {
                                Circle()
                                    .fill(Color.background.opacity(0.3))
                                    .frame(width: 130, height: 130)

								Circle()
                                    .fill(Color.white)
                                    .frame(width: 100, height: 100)

                                Image(systemName: pages[index].image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.background)
									.symbolEffect(.breathe.plain.byLayer, options: .repeat(.continuous))
                            }
                            .shadow(color: .blue.opacity(0.2), radius: 10, x: 0, y: 5)

                            // 제목
                            Text(pages[index].title)
                                .font(.system(size: 28, weight: .bold))
                                .transition(.move(edge: .trailing).combined(with: .opacity))
                            
                            // 설명
                            Text(pages[index].description)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 32)
                                .transition(.move(edge: .trailing).combined(with: .opacity))
                            
                            Spacer()
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // 버튼 영역
                HStack {
                    if currentPage > 0 {
                        Button {
                            withAnimation {
                                currentPage -= 1
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("이전")
                            }
                            .foregroundColor(.background)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(1.0))
                            .cornerRadius(20)
                        }
                    }
                    
                    Spacer()
                    
                    if currentPage < pages.count - 1 {
                        Button {
                            withAnimation {
                                currentPage += 1
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text("다음")
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.background)
                            .cornerRadius(20)
                        }
                    } else {
                        Button {
                            dismiss()
                        } label: {
                            Text("시작하기")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.background)
                                .cornerRadius(20)
                                .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
                        }
                        .buttonStyle(PressableButtonStyle())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}

// 버튼 눌렀을 때 효과
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}


#Preview {
    OnboardingView()
}
