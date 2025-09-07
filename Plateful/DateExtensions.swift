//
//  DateExtensions.swift
//  Plateful
//
//  Created by Полина Соколова on 11.08.25.
//

import Foundation

extension Calendar {
    static let app: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 2               // 2 = Monday
        cal.locale = Locale(identifier: "en_US_POSIX")
        cal.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        return cal
    }()
}

extension Date {
    /// Надёжно возвращает ПОНЕДЕЛЬНИК недели для данной даты
    func startOfWeekMonday() -> Date {
        let cal = Calendar.app
        if let interval = cal.dateInterval(of: .weekOfYear, for: self) {
            // interval.start = первый день недели для заданного календаря (у нас — понедельник)
            return interval.start
        }
        return self
    }

    /// Сдвиг на целые дни
    func adding(days: Int) -> Date {
        Calendar.app.date(byAdding: .day, value: days, to: self) ?? self
    }

    /// Формат для списка дней: «Пн, 25.08.2025»
    func dayTitle() -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ru_RU")
        df.timeZone = Calendar.app.timeZone
        df.dateFormat = "EE, dd.MM.yyyy"
        return df.string(from: self)
    }
}

