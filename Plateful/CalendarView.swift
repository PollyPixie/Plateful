//
//  CalendarView.swift
//  Plateful
//
//  Created by Полина Соколова on 11.08.25.
//

import SwiftUI

struct CalendarView: View {
    @State private var selected = Date()
    @State private var goToDetail = false
    private let weekStore = WeekStore()

    private var dateRange: ClosedRange<Date> {
        let start = weekStore.anchorMonday
        let end = Calendar.app.date(byAdding: .year, value: 1, to: start) ?? start
        return start...end
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                DatePicker(
                    "",
                    selection: $selected,
                    in: dateRange,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .tint(.brandOlive)
                .onChange(of: selected, initial: false) {
                    goToDetail = true
                }

                Text("Start: \(weekStore.anchorMonday.dayTitle())")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .navigationTitle("Calendar")
            // ✅ Новый способ навигации (iOS 16+)
            .navigationDestination(isPresented: $goToDetail) {
                DayDetailView(date: selected)
            }
        }
    }
}
