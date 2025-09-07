//
//  WeekStore.swift
//  Plateful
//
//  Created by Полина Соколова on 11.08.25.
//

import Foundation
import Combine

final class WeekStore: ObservableObject {
    @Published var anchorMonday: Date
    private let anchorKey = "week.anchor.monday.v1"   // лучше неймспейсить ключ

    init() {
        // если якорь уже сохранён — читаем и нормализуем к понедельнику
        if let ts = UserDefaults.standard.object(forKey: anchorKey) as? TimeInterval {
            anchorMonday = Date(timeIntervalSince1970: ts).startOfWeekMonday()
            return
        }

        // первый запуск: фиксируем ПН 08.09.2025
        var comps = DateComponents()
        comps.calendar = Calendar.app
        comps.timeZone = Calendar.app.timeZone
        comps.year = 2025
        comps.month = 9
        comps.day = 8

        anchorMonday = (comps.date ?? Date()).startOfWeekMonday()
        UserDefaults.standard.set(anchorMonday.timeIntervalSince1970, forKey: anchorKey)
    }

    func daysOfCurrentWeek() -> [Date] {
        (0..<7).compactMap { Calendar.app.date(byAdding: .day, value: $0, to: anchorMonday) }
    }

    func weekTitle() -> String {
        let first = anchorMonday
        let last  = Calendar.app.date(byAdding: .day, value: 6, to: first) ?? first

        let dfDay = DateFormatter()
        dfDay.locale = Locale(identifier: "en_US_POSIX")
        dfDay.timeZone = Calendar.app.timeZone
        dfDay.dateFormat = "dd"

        let dfMonth = DateFormatter()
        dfMonth.locale = Locale(identifier: "en_US_POSIX")
        dfMonth.timeZone = Calendar.app.timeZone
        dfMonth.dateFormat = "MMM yyyy"

        return "\(dfDay.string(from: first))–\(dfDay.string(from: last)) \(dfMonth.string(from: last))"
    }

    func setAnchor(to date: Date) {
        let monday = date.startOfWeekMonday()
        anchorMonday = monday
        UserDefaults.standard.set(monday.timeIntervalSince1970, forKey: anchorKey)
    }
}





