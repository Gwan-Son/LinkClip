import SwiftUI

struct ReadingReminderView: View {
    let link: LinkItem

    @Environment(\.dismiss) private var dismiss
    @State private var date: Date
    @State private var errorMessage: String?

    init(link: LinkItem) {
        self.link = link
        let saved = UserDefaults.shared.linkReminderDates[link.id]
        _date = State(initialValue: saved ?? Date().addingTimeInterval(3600))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(link.title)
                    DatePicker(
                        "알림 시간",
                        selection: $date,
                        in: Date()...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }

                if UserDefaults.shared.linkReminderDates[link.id] != nil {
                    Button("알림 취소", role: .destructive) {
                        ReadingReminderService.cancel(linkID: link.id)
                        dismiss()
                    }
                }
            }
            .navigationTitle("읽기 알림")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        Task {
                            do {
                                try await ReadingReminderService.schedule(
                                    linkID: link.id,
                                    title: link.title,
                                    date: date
                                )
                                dismiss()
                            } catch {
                                errorMessage = error.localizedDescription
                            }
                        }
                    }
                }
            }
            .alert("알림 오류", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }
}
