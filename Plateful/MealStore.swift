//
//  MealStore.swift
//  Plateful
//
//  Created by Полина Соколова on 02.09.25.
//

import Foundation

// Что храним для конкретного дня
struct DayPlan: Codable, Hashable {
    var breakfast: String
    var lunch: String
    var dinner: String
    var ingredients: [String]
}

final class MealStore: ObservableObject {
    @Published private(set) var plans: [String: DayPlan] = [:] {
        didSet { save() }
    }
    
    @Published private(set) var availability: [String: Set<String>] = [:] {
        didSet { saveAvailability() }
    }
    
    private let availabilityKey = "meal.have.v1"
    private let storageKey = "meal.plans.v1"

    // MARK: - Публичное API

    /// Получить план на дату (если нет — создаём из демо-данных MealData)
    func plan(for date: Date) -> DayPlan {
        let k = Self.key(for: date)
        if let p = plans[k] { return p }

        // Seed лишь для отображения, без записи в @Published:
        let meals = MealData.meals(for: date)
        return DayPlan(
            breakfast: meals.count > 0 ? meals[0] : "",
            lunch:     meals.count > 1 ? meals[1] : "",
            dinner:    meals.count > 2 ? meals[2] : "",
            ingredients: MealData.ingredients(for: date)
        )
    }


    /// Полностью заменить план на дату
    func update(_ plan: DayPlan, for date: Date) {
        plans[Self.key(for: date)] = plan
    }

    /// Изменить одно из блюд (с сохранением)
    enum MealKind { case breakfast, lunch, dinner }
    func setMeal(_ kind: MealKind, to text: String, for date: Date) {
        var p = plan(for: date)
        switch kind {
        case .breakfast: p.breakfast = text
        case .lunch:     p.lunch     = text
        case .dinner:    p.dinner    = text
        }
        update(p, for: date)
    }

    /// Добавить ингредиент (уникально, с тримом)
    func addIngredient(_ name: String, to date: Date) {
        let cleaned = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return }
        var p = plan(for: date)
        if !p.ingredients.contains(where: { $0.caseInsensitiveCompare(cleaned) == .orderedSame }) {
            p.ingredients.append(cleaned)
            update(p, for: date)
        }
    }

    /// Удалить ингредиенты по индексам
    func removeIngredients(at offsets: IndexSet, for date: Date) {
        var p = plan(for: date)
        let removed = offsets.map { p.ingredients[$0] }
        p.ingredients.remove(atOffsets: offsets)
        update(p, for: date)

        // убираем соответствующие «галочки» из availability
        let k = Self.key(for: date)
        if var set = availability[k] {
            removed.forEach { set.remove($0) }
            availability[k] = set
        }
    }
    
    func isHave(_ name: String, on date: Date) -> Bool {
        let k = Self.key(for: date)
        let cleaned = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return availability[k]?.contains(cleaned) ?? false
    }

    func toggleHave(_ name: String, on date: Date) {
        let k = Self.key(for: date)
        var set = availability[k] ?? []
        let cleaned = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if set.contains(cleaned) {
            set.remove(cleaned)
        } else {
            set.insert(cleaned)
        }
        availability[k] = set
    }

    // MARK: - Хелперы ключа даты и (де)сериализация

    private static func key(for date: Date) -> String {
        let df = DateFormatter()
        df.calendar = Calendar.app
        df.timeZone = Calendar.app.timeZone
        df.locale   = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "yyyy-MM-dd"        // безопасно для словаря/ключа
        return df.string(from: date)
    }

    private func save() {
        if let data = try? JSONEncoder().encode(plans) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    private func saveAvailability() {
        // кодируем Set как массив строк
        let dict = availability.mapValues { Array($0) }
        if let data = try? JSONEncoder().encode(dict) {
            UserDefaults.standard.set(data, forKey: availabilityKey)
        }
    }

    private func loadAvailability() {
        guard let data = UserDefaults.standard.data(forKey: availabilityKey),
              let dict = try? JSONDecoder().decode([String:[String]].self, from: data)
        else { return }
        availability = dict.mapValues { Set($0) }
    }

    init() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([String: DayPlan].self, from: data) {
            plans = decoded
        }
        
        loadAvailability()
    }
}
