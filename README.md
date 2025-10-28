# LinkToMe

### 가장 심플한 링크 저장소 LinkClip


<a href="https://apps.apple.com/kr/app/linkclip-%EC%86%90%EC%89%AC%EC%9A%B4-%EB%A7%81%ED%81%AC-%EC%A0%80%EC%9E%A5/id6744954526">
 <img src="https://github.com/user-attachments/assets/4a8856c1-efb7-4b7b-82cc-1116b50c5678" width="250px">
</div>

## 목차
- [🚀 개발 기간](#-개발-기간)
- [💻 개발 환경](#-개발-환경)
- [👀 미리 보기](#-미리-보기)
- [📝개발 내용](#-개발-내용)
- [📁 파일 구조](#-파일-구조)

---

# 🚀 개발 기간
25.02.18 ~ 25.04.23 (약 2개월)
25.06.04 ~ ing (추가기능 및 로컬라이징) - Spotlight 검색 기능 추가 완료(2025.10.28)

# 💻 개발 환경
- `XCode 16.3`
- `Swift 6.0.0`


# 👀 미리 보기
<div>
 <img src="https://github.com/user-attachments/assets/4c1a87b7-dd1d-4d2e-9fc5-e8b4f41b336d" width=45%>
 <img src="https://github.com/user-attachments/assets/0ed9575a-66fd-4a53-b7d4-db43c8437eff" width=45%>
</div>

# 📝 개발 내용

### 앱의 방향성

- 앱의 방향성에 대해서 개발을 진행하기 전 생각했던 점들을 정리할까 합니다.
먼저, URL 저장소의 필요성을 느낀건 개발 공부나 여러가지 글을 읽다보면 나중에 찾아볼 때가 생깁니다. 그래서 유용하게 사용하던 것이 카카오톡의 ‘나에게 보내기’ 기능이었습니다. 하지만 나에게 보내기 기능은 정렬기능과 카테고리 기능이 없어 저장해놓은 링크에 대한 정보를 찾기 쉽지 않았습니다.
- 왜 ShareExtension인가?
일반적으로 링크를 저장하는 방법은 copy & paste 방식으로 해당 URL을 직접 복사하여 저장하는 방식이었습니다. 하지만 ShareExtension을 사용하면 사용자가 직접적으로 URL을 복사하지 않고 앱으로 데이터를 보낼 수 있으며 추가적으로 해당 URL에 대한 정보나 개인 메모 등을 입력할 수 있었습니다.

### 심플한 디자인

- 앱의 UI를 설계할 때 가장 먼저 고민해야하는 것은 사용자가 불편함을 느끼지 않냐 입니다. 추후에 앱에 기능을 추가할 때 기존 인터페이스를 유지할 수 있도록 TabView를 사용하여 사용자에게 여러 기능을 제공할 수 있게 설계하였습니다.
- 온보딩 화면을 넣자!
앱을 처음 설치한 사용자는 사용법을 모르기 때문에 앱에 대한 간략한 설명을 제공해야 합니다. 현재는 아이콘과 텍스트로만 온보딩을 구성하였지만 추후에 gif나 영상을 통해 더욱 직관적으로 온보딩을 수정할 예정입니다.

<div>
 <img src="https://github.com/user-attachments/assets/8571503e-600c-4bb1-9e3e-35c5d2abf887" width="33%">
 <img src="https://github.com/user-attachments/assets/6f90d16a-865c-433a-a716-a81330c53903" width="33%">
 <img src="https://github.com/user-attachments/assets/e1d3941b-9eee-4474-b854-11c2ea71a3f8" width="33%">
</div>

# 📁 파일 구조
```
.
├── LinkClip
│   ├── Assets.xcassets
│   │   ├── AccentColor.colorset
│   │   │   └── Contents.json
│   │   ├── AppIcon.appiconset
│   │   │   ├── 1024.png
│   │   │   ├── 114.png
│   │   │   ├── 120 1.png
│   │   │   ├── 120.png
│   │   │   ├── 180.png
│   │   │   ├── 40.png
│   │   │   ├── 58.png
│   │   │   ├── 60.png
│   │   │   ├── 80.png
│   │   │   ├── 87.png
│   │   │   └── Contents.json
│   │   ├── BackgroundColor.colorset
│   │   │   └── Contents.json
│   │   ├── Contents.json
│   │   ├── MainColor.colorset
│   │   │   └── Contents.json
│   │   └── SettingImage.imageset
│   │       ├── 58.png
│   │       └── Contents.json
│   ├── CategoryView
│   │   ├── AddCategoryView.swift
│   │   ├── CategoryManagementView.swift
│   │   └── CategoryView.swift
│   ├── Components
│   │   ├── Category.swift
│   │   ├── LinkItem.swift
│   │   ├── SearchScope.swift
│   │   ├── SortOption.swift
│   │   └── ToastModifier.swift
│   ├── LinkClip.entitlements
│   ├── LinkClip.swift
│   ├── MainView
│   │   ├── EditView.swift
│   │   ├── HomeView.swift
│   │   ├── LinkRowView.swift
│   │   ├── MainView.swift
│   │   ├── MainViewModel.swift
│   │   ├── NothingView.swift
│   │   └── OnboardingView.swift
│   ├── Preview Content
│   │   └── Preview Assets.xcassets
│   │       └── Contents.json
│   ├── SettingView
│   │   ├── MailView.swift
│   │   └── SettingView.swift
│   └── Shared
│       ├── ShareError.swift
│       ├── ShareView.swift
│       └── SwiftDataContainer.swift
├── LinkClip.xcodeproj
│   ├── project.pbxproj
│   ├── project.xcworkspace
│   │   ├── contents.xcworkspacedata
│   │   ├── xcshareddata
│   │   │   └── swiftpm
│   │   │       └── configuration
│   │   └── xcuserdata
│   │       └── simgwanhyeok.xcuserdatad
│   │           └── UserInterfaceState.xcuserstate
│   ├── xcshareddata
│   │   └── xcschemes
│   │       ├── LinkToMe.xcscheme
│   │       └── ShareViewController.xcscheme
│   └── xcuserdata
│       └── simgwanhyeok.xcuserdatad
│           ├── xcdebugger
│           │   └── Breakpoints_v2.xcbkptlist
│           └── xcschemes
│               └── xcschememanagement.plist
├── privacy
│   ├── privacy.md
│   └── service.md
├── README.md
└── ShareViewController
    ├── Base.lproj
    ├── Info.plist
    ├── ShareViewController.entitlements
    └── ShareViewController.swift

31 directories, 53 files
```
