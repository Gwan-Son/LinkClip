import SwiftData
import SwiftUI

private struct StarterTag: Identifiable {
    let id: String
    let name: String
    let icon: String
    let color: String

    static var all: [StarterTag] {
        [
            .init(id: "work", name: String(localized: "업무"), icon: "briefcase", color: "5B8DEF"),
            .init(id: "study", name: String(localized: "학습"), icon: "book", color: "7A6FF0"),
            .init(id: "news", name: String(localized: "뉴스"), icon: "newspaper", color: "E98A3A"),
            .init(id: "ideas", name: String(localized: "아이디어"), icon: "lightbulb", color: "E5B72F"),
            .init(id: "shopping", name: String(localized: "쇼핑"), icon: "cart", color: "E46C8C"),
        ]
    }
}

struct OnboardingGateView: View {
    @AppStorage(
        UserDefaults.Keys.onboardingVersion,
        store: UserDefaults.shared
    ) private var onboardingVersion = 0

    var body: some View {
        if onboardingVersion < 2 {
            OnboardingView {
                onboardingVersion = 2
            }
        } else {
            HomeView()
        }
    }
}

struct OnboardingView: View {
    let showsCloseButton: Bool
    let offersStarterTags: Bool
    let onComplete: () -> Void

    @Environment(\.modelContext) private var modelContext
    @State private var page = 0
    @State private var selectedStarterTagIDs = Set(StarterTag.all.map(\.id))
    @State private var errorMessage: String?

    init(
        showsCloseButton: Bool = false,
        offersStarterTags: Bool = true,
        onComplete: @escaping () -> Void
    ) {
        self.showsCloseButton = showsCloseButton
        self.offersStarterTags = offersStarterTags
        self.onComplete = onComplete
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                if showsCloseButton {
                    Button(action: onComplete) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityLabel("닫기")
                }
            }
            .frame(height: 44)
            .padding(.horizontal, 20)

            TabView(selection: $page) {
                onboardingPage(
                    title: "나중에 읽을 링크를\n한곳에 모아보세요",
                    description: "웹사이트를 저장하고, AI 요약과 태그로\n간편하게 정리할 수 있어요."
                ) {
                    LibraryOnboardingIllustration()
                }
                .tag(0)

                onboardingPage(
                    title: "어디서든 바로 저장하세요",
                    description: "Safari나 다른 앱에서 공유 버튼을 누르고\nLinkClip을 선택하면 링크가 저장됩니다."
                ) {
                    ShareOnboardingIllustration()
                }
                .tag(1)

                if offersStarterTags {
                    starterTagsPage.tag(2)
                } else {
                    onboardingPage(
                        title: "필요한 내용만\n빠르게 확인하세요",
                        description: "AI가 긴 글의 핵심을 정리해드려요.\n태그, 즐겨찾기, 나중에 읽기로 관리할 수 있어요.\n\n요약 시 URL과 웹페이지 내용이 서버로 전송됩니다."
                    ) {
                        SummaryOnboardingIllustration()
                    }
                    .tag(2)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            HStack(spacing: 8) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(index == page ? Color.mainColor : Color.secondary.opacity(0.25))
                        .frame(width: 8, height: 8)
                }
            }
            .accessibilityHidden(true)
            .padding(.bottom, 24)

            Button(action: advance) {
                Text(buttonTitle)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(.mainColor)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .alert("태그를 추가하지 못했습니다", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("확인", role: .cancel) { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private var buttonTitle: LocalizedStringKey {
        switch page {
        case 0: "시작하기"
        case 1: "다음"
        default:
            if offersStarterTags {
                selectedStarterTagIDs.isEmpty ? "태그 없이 시작" : "추천 태그 추가하고 시작"
            } else {
                "LinkClip 시작하기"
            }
        }
    }

    private func advance() {
        if page < 2 {
            withAnimation { page += 1 }
        } else {
            finishOnboarding()
        }
    }

    private var starterTagsPage: some View {
        VStack(spacing: 14) {
            VStack(spacing: 8) {
                Text("추천 태그로 시작할까요?")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                Text("필요한 태그만 선택해주세요.\n언제든 수정하거나 삭제할 수 있어요.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            SummaryOnboardingIllustration()
                .frame(maxWidth: .infinity, maxHeight: 170)
                .clipped()
                .accessibilityHidden(true)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 96))], spacing: 10) {
                ForEach(StarterTag.all) { tag in
                    let isSelected = selectedStarterTagIDs.contains(tag.id)
                    Button {
                        if isSelected {
                            selectedStarterTagIDs.remove(tag.id)
                        } else {
                            selectedStarterTagIDs.insert(tag.id)
                        }
                    } label: {
                        Label(tag.name, systemImage: isSelected ? "checkmark.circle.fill" : tag.icon)
                            .font(.subheadline.weight(.medium))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 9)
                    }
                    .buttonStyle(.bordered)
                    .tint(isSelected ? Color(hex: tag.color) : .secondary)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
    }

    private func finishOnboarding() {
        guard offersStarterTags, !selectedStarterTagIDs.isEmpty else {
            onComplete()
            return
        }

        do {
            let existing = try modelContext.fetch(FetchDescriptor<CategoryItem>())
            for tag in StarterTag.all where selectedStarterTagIDs.contains(tag.id) {
                guard !existing.contains(where: {
                    $0.name.localizedCaseInsensitiveCompare(tag.name) == .orderedSame
                }) else { continue }
                modelContext.insert(CategoryItem(name: tag.name, icon: tag.icon, color: tag.color))
            }
            try modelContext.save()
            onComplete()
        } catch {
            modelContext.rollback()
            errorMessage = error.localizedDescription
        }
    }

    private func onboardingPage<Illustration: View>(
        title: LocalizedStringKey,
        description: LocalizedStringKey,
        @ViewBuilder illustration: () -> Illustration
    ) -> some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Text(title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)

                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            illustration()
                .frame(maxWidth: .infinity, maxHeight: 330)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
    }
}

private struct LibraryOnboardingIllustration: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.mainColor.opacity(0.08))
                .frame(width: 280, height: 270)

            VStack(spacing: -8) {
                linkCard(icon: "globe", color: .blue, offset: -16)
                linkCard(icon: "play.fill", color: .mainColor, offset: 10)
                linkCard(icon: "doc.text.fill", color: .purple, offset: -6)
            }
            .offset(y: -22)

            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.mainColor.opacity(0.18))
                    .frame(width: 160, height: 82)
                Image(systemName: "tray.full.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.mainColor)
                    .offset(y: 14)
            }
            .offset(y: 92)
        }
    }

    private func linkCard(icon: String, color: Color, offset: CGFloat) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 30, height: 30)
                .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
            VStack(alignment: .leading, spacing: 5) {
                Capsule().fill(Color.primary.opacity(0.22)).frame(width: 92, height: 7)
                Capsule().fill(Color.primary.opacity(0.09)).frame(width: 130, height: 6)
            }
        }
        .padding(12)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
        .offset(x: offset)
    }
}

private struct ShareOnboardingIllustration: View {
    var body: some View {
        VStack(spacing: 18) {
            VStack(alignment: .leading, spacing: 14) {
                Capsule()
                    .fill(Color.secondary.opacity(0.25))
                    .frame(width: 64, height: 5)
                    .frame(maxWidth: .infinity)

                HStack(spacing: 16) {
                    shareIcon("airplayaudio", title: "AirDrop", color: .blue)
                    shareIcon("message.fill", title: "메시지", color: .green)
                    shareIcon("link", title: "LinkClip", color: .mainColor, selected: true)
                    shareIcon("ellipsis", title: "더보기", color: .secondary)
                }
            }
            .padding(18)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 12, y: 5)

            HStack(spacing: 14) {
                step("square.and.arrow.up", "공유")
                Image(systemName: "arrow.right").foregroundStyle(.tertiary)
                step("link", "LinkClip")
                Image(systemName: "arrow.right").foregroundStyle(.tertiary)
                step("tray.and.arrow.down", "저장")
            }
            .padding(16)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .padding(.horizontal, 12)
    }

    private func shareIcon(
        _ icon: String,
        title: String,
        color: Color,
        selected: Bool = false
    ) -> some View {
        VStack(spacing: 7) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 48, height: 48)
                .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 13))
                .overlay {
                    if selected {
                        RoundedRectangle(cornerRadius: 13).stroke(Color.mainColor, lineWidth: 2)
                    }
                }
            Text(title).font(.caption2).lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }

    private func step(_ icon: String, _ title: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.mainColor)
            Text(title).font(.caption)
        }
    }
}

private struct SummaryOnboardingIllustration: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundStyle(Color.mainColor)
                    .frame(width: 48, height: 48)
                    .background(Color.mainColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 13))
                VStack(alignment: .leading, spacing: 6) {
                    Capsule().fill(Color.primary.opacity(0.28)).frame(width: 130, height: 9)
                    Capsule().fill(Color.primary.opacity(0.10)).frame(width: 90, height: 7)
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                summaryLine(1)
                summaryLine(0.92)
                summaryLine(0.72)
            }

            HStack(spacing: 8) {
                tag("생산성")
                tag("인사이트")
                tag("AI")
            }

            Divider()

            HStack {
                Image(systemName: "star")
                Spacer()
                Image(systemName: "bookmark")
                Spacer()
                Image(systemName: "clock")
            }
            .font(.title3)
            .foregroundStyle(Color.mainColor)
        }
        .padding(22)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 14, y: 6)
        .padding(.horizontal, 18)
    }

    private func summaryLine(_ width: CGFloat) -> some View {
        Capsule()
            .fill(Color.primary.opacity(0.12))
            .frame(maxWidth: .infinity)
            .frame(height: 9)
            .scaleEffect(x: width, anchor: .leading)
    }

    private func tag(_ title: String) -> some View {
        Text("# \(title)")
            .font(.caption)
            .foregroundStyle(Color.mainColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.mainColor.opacity(0.10), in: Capsule())
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
