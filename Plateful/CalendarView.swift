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

    // Диапазон дат: от якорного понедельника на 1 год
    private var dateRange: ClosedRange<Date> {
        let start = weekStore.anchorMonday
        let end = Calendar.app.date(byAdding: .year, value: 1, to: start) ?? start
        return start...end
    }

    // Русская локаль и календарь (понедельник — первый день)
    private let ruLocale = Locale(identifier: "ru_RU")
    private var ruCalendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.locale = Locale(identifier: "ru_RU")
        c.firstWeekday = 2
        c.timeZone = Calendar.app.timeZone
        return c
    }()

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
                .environment(\.locale, ruLocale)
                .environment(\.calendar, ruCalendar)
                .onChange(of: selected, initial: false) {
                    goToDetail = true
                }

                Text("Начало: \(weekStore.anchorMonday.dayTitle())")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .navigationTitle("Календарь")
            .navigationDestination(isPresented: $goToDetail) {
                DayDetailView(date: selected)
            }
        }
    }
}

