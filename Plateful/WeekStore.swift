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
        dfDay.locale = Locale(identifier: "ru_RU")
        dfDay.timeZone = Calendar.app.timeZone
        dfDay.dateFormat = "dd"

        let dfMonth = DateFormatter()
        dfMonth.locale = Locale(identifier: "ru_RU")
        dfMonth.timeZone = Calendar.app.timeZone
        dfMonth.dateFormat = "LLL yyyy"

        return "\(dfDay.string(from: first))–\(dfDay.string(from: last)) \(dfMonth.string(from: last))"
    }

    func setAnchor(to date: Date) {
        let monday = date.startOfWeekMonday()
        anchorMonday = monday
        UserDefaults.standard.set(monday.timeIntervalSince1970, forKey: anchorKey)
    }
    
    // Для экспорта: timestamp якоря
    func anchorTimestamp() -> TimeInterval {
        anchorMonday.timeIntervalSince1970
    }

    // Для импорта: выставить якорь из timestamp (с нормализацией к понедельнику)
    func setAnchor(timestamp: TimeInterval) {
        let monday = Date(timeIntervalSince1970: timestamp).startOfWeekMonday()
        anchorMonday = monday
        UserDefaults.standard.set(monday.timeIntervalSince1970, forKey: anchorKey)
    }
    
    func ensureCurrentWeek() {
        let todayMonday = Date().startOfWeekMonday()
        if anchorMonday != todayMonday {
            setAnchor(to: Date())
        }
    }
    
    // MARK: - Three-pane weeks (prev/current/next)
    /// Понедельник недели относительно якоря: -1 = предыдущая, 0 = текущая, +1 = следующая
    func monday(offset: Int) -> Date {
        precondition((-1...1).contains(offset), "offset must be -1, 0, or +1")
        return Calendar.app.date(byAdding: .day, value: offset * 7, to: anchorMonday) ?? anchorMonday
    }

    /// Дни недели для указанного смещения (7 дат, Пн—Вс)
    func daysOfWeek(offset: Int) -> [Date] {
        let start = monday(offset: offset)
        return (0..<7).compactMap { Calendar.app.date(byAdding: .day, value: $0, to: start) }
    }

    /// Заголовок «08–14 сент 2025» для недели со смещением
    func weekTitle(offset: Int) -> String {
        let first = monday(offset: offset)
        let last  = Calendar.app.date(byAdding: .day, value: 6, to: first) ?? first

        let dfDay = DateFormatter()
        dfDay.locale = Locale(identifier: "ru_RU")
        dfDay.timeZone = Calendar.app.timeZone
        dfDay.dateFormat = "dd"

        let dfMonth = DateFormatter()
        dfMonth.locale = Locale(identifier: "ru_RU")
        dfMonth.timeZone = Calendar.app.timeZone
        dfMonth.dateFormat = "LLL yyyy"

        return "\(dfDay.string(from: first))–\(dfDay.string(from: last)) \(dfMonth.string(from: last))"
    }
}
