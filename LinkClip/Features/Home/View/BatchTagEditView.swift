import SwiftData
import SwiftUI

struct BatchTagEditView: View {
    let links: [LinkItem]
    let onChange: () -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CategoryItem.createdDate) private var fetchedCategories: [CategoryItem]
    @State private var errorMessage: String?

    private var categories: [CategoryItem] {
        let order = Dictionary(
            uniqueKeysWithValues: UserDefaults.shared.categoryOrder.enumerated().map { ($1, $0) }
        )
        return fetchedCategories.sorted { (order[$0.id] ?? .max) < (order[$1.id] ?? .max) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if categories.isEmpty {
                    ContentUnavailableView(
                        "등록된 태그가 없습니다",
                        systemImage: "tag",
                        description: Text("홈에서 태그를 먼저 추가해주세요.")
                    )
                } else {
                    List(categories) { category in
                        Button {
                            toggle(category)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: category.icon)
                                    .foregroundStyle(Color(hex: category.safeColor))
                                    .frame(width: 28)

                                Text(category.name)
                                    .foregroundStyle(.primary)

                                Spacer()

                                Image(systemName: state(of: category).icon)
                                    .foregroundStyle(state(of: category).color)
                                    .font(.title3)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle(links.count == 1 ? "태그 편집" : "\(links.count)개 링크의 태그")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("완료") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                Text("태그를 누르면 선택한 링크 전체에 추가되거나 해제됩니다.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.bar)
            }
            .alert("태그를 저장하지 못했습니다", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("확인", role: .cancel) { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    private func state(of category: CategoryItem) -> TagAssignmentState {
        let count = links.lazy.filter { link in
            link.categories?.contains { $0.id == category.id } == true
        }.count
        if count == 0 { return .none }
        return count == links.count ? .all : .some
    }

    private func toggle(_ category: CategoryItem) {
        let shouldRemove = state(of: category) == .all
        for link in links {
            var assigned = link.categories ?? []
            if shouldRemove {
                assigned.removeAll { $0.id == category.id }
            } else if !assigned.contains(where: { $0.id == category.id }) {
                assigned.append(category)
            }
            link.categories = assigned
        }
        do {
            try modelContext.save()
            onChange()
        } catch {
            modelContext.rollback()
            errorMessage = error.localizedDescription
        }
    }
}

private enum TagAssignmentState {
    case none, some, all

    var icon: String {
        switch self {
        case .none: "circle"
        case .some: "minus.circle.fill"
        case .all: "checkmark.circle.fill"
        }
    }

    var color: Color {
        self == .none ? .secondary : .mainColor
    }
}
