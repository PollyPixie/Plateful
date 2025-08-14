//
//  WeekStore.swift
//  Plateful
//
//  Created by Полина Соколова on 11.08.25.
//

// WeekStore.swift
import Foundation
import Combine

final class WeekStore: ObservableObject {
    // Храним якорный понедельник и читаем/пишем его в UserDefaults
    @Published var anchorMonday: Date
    private let anchorKey = "anchorMonday"

    init() {
        if let saved = UserDefaults.standard.object(forKey: anchorKey) as? TimeInterval {
            // Всегда нормализуем к понедельнику
            anchorMonday = Date(timeIntervalSince1970: saved).startOfWeekMonday()
        } else {
            // Первый запуск: фиксируем ПН 25.08.2025
            var comps = DateComponents()
            comps.year = 2025
            comps.month = 8
            comps.day = 25
            comps.hour = 0
            comps.minute = 0
            comps.second = 0

            anchorMonday = Calendar.app.date(from: comps)?.startOfWeekMonday()
            ?? Date().startOfWeekMonday()

            UserDefaults.standard.set(anchorMonday.timeIntervalSince1970, forKey: anchorKey)
        }
    }

    /// Массив дат текущей недели (Пн…Вс), начиная от anchorMonday
    func daysOfCurrentWeek() -> [Date] {
        (0..<7).compactMap { Calendar.app.date(byAdding: .day, value: $0, to: anchorMonday) }
    }

    /// Заголовок вида "25–31 Aug 2025"
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

    /// (опционально) Сбросить якорь вручную, если захочешь поменять старт недели
    func setAnchor(to date: Date) {
        let monday = date.startOfWeekMonday()
        anchorMonday = monday
        UserDefaults.standard.set(monday.timeIntervalSince1970, forKey: anchorKey)
    }
}




