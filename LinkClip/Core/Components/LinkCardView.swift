//
//  LinkCardView.swift
//  LinkClip
//
//  Created by 심관혁 on 12/16/25.
//

import SwiftUI

struct LinkCardView: View {
    let link: LinkItem?
    let isOnboarding: Bool
    let onboardingIndex: Int?

    init(
        link: LinkItem? = nil,
        isOnboarding: Bool = false,
        onboardingIndex: Int? = nil
    ) {
        self.link = link
        self.isOnboarding = isOnboarding
        self.onboardingIndex = onboardingIndex
    }

    var body: some View {
        VStack {
            Spacer()
                .frame(height: 10)

            if isOnboarding {
                let onboardingData = getOnboardingData(
                    for: onboardingIndex ?? 0
                )

                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(onboardingData.color.opacity(0.1))
                            .frame(width: 50, height: 50)

                        Image(systemName: onboardingData.icon)
                            .font(.system(size: 24))
                            .foregroundColor(onboardingData.color)
                    }

                    VStack(spacing: 8) {
                        Text(onboardingData.title)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.black)

                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(
                                onboardingData.steps.indices,
                                id: \.self
                            ) { stepIndex in
                                let step = onboardingData.steps[stepIndex]
                                HStack(spacing: 6) {
                                    Text("\(stepIndex + 1)")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(onboardingData.color)
                                        .frame(width: 14, height: 14)
                                        .background(
                                            onboardingData.color.opacity(0.2)
                                        )
                                        .clipShape(Circle())

                                    Text(step)
                                        .font(.system(size: 11))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
                .frame(height: 180)
                .padding(.horizontal, 8)
            } else if let link = link {
                CachedAsyncImage(
                    primaryURL: link.imageURL.flatMap(URL.init),
                    fallbackURL: link.faviconURL.flatMap(URL.init)
                )
                .frame(width: 180, height: 100)
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                Text(link.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                    .lineLimit(2)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 10)
            }
        }
        .frame(width: 200, height: 180)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func getOnboardingData(for index: Int) -> OnboardingData {
        switch index {
        case 0:
            return OnboardingData(
                icon: "link.badge.plus",
                color: .blue,
                title: String(localized: "링크 쉽게 저장하기", defaultValue: "Save Links Easily"),
                steps: [
                    String(localized: "Safari에서 공유 버튼 탭", defaultValue: "Tap share button in Safari"),
                    String(localized: "LinkClip 선택", defaultValue: "Select LinkClip"),
                    String(localized: "제목과 메모 추가", defaultValue: "Add title and memo")
                ]
            )
        case 1:
            return OnboardingData(
                icon: "tag",
                color: .green,
                title: String(localized: "태그로 정리하기", defaultValue: "Organize with Tags"),
                steps: [
                    String(localized: "카테고리 생성", defaultValue: "Create categories"),
                    String(localized: "링크에 태그 달기", defaultValue: "Tag your links"),
                    String(localized: "필터로 검색", defaultValue: "Search with filters")
                ]
            )
        case 2:
            return OnboardingData(
                icon: "magnifyingglass",
                color: .orange,
                title: String(localized: "빠른 검색", defaultValue: "Quick Search"),
                steps: [
                    String(localized: "검색창에 키워드 입력", defaultValue: "Enter keywords in search bar"),
                    String(localized: "태그나 제목으로 찾기", defaultValue: "Find by tags or titles"),
                    String(localized: "즉시 링크 열기", defaultValue: "Open links instantly")
                ]
            )
        default:
            return OnboardingData(
                icon: "link.badge.plus",
                color: .blue,
                title: String(localized: "링크 저장 가이드", defaultValue: "Link Saving Guide"),
                steps: [
                    String(localized: "Safari 공유", defaultValue: "Safari Share"),
                    String(localized: "LinkClip 선택", defaultValue: "Select LinkClip"),
                    String(localized: "저장 완료", defaultValue: "Save Complete")
                ]
            )
        }
    }
}

struct OnboardingData {
    let icon: String
    let color: Color
    let title: String
    let steps: [String]
}
