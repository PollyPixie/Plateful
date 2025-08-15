//
//  MealData.swift
//  Plateful
//
//  Created by Полина Соколова on 14.08.25.
//

import Foundation

enum MealData {
    static func ingredients(for date: Date) -> [String] {
        // Пример: разные наборы по дню недели — просто чтобы пощупать UX
        let weekday = Calendar.app.component(.weekday, from: date)
        switch weekday {
        case 2: return ["Овсянка", "Бананы", "Молоко", "Хлеб", "Тунец", "Майонез"]
        case 3: return ["Рис", "Курица", "Соевый соус", "Лук", "Морковь"]
        case 4: return ["Паста", "Томаты", "Сыр", "Оливковое масло", "Чеснок"]
        case 5: return ["Гречка", "Грибы", "Сметана", "Зелень"]
        case 6: return ["Яйца", "Хлеб", "Сыр", "Помидоры"]
        case 7: return ["Йогурт", "Мюсли", "Ягоды", "Мёд"]
        default: return ["Картофель", "Морковь", "Лук", "Хлеб"]
        }
    }
    
    /// Три блюда (завтрак, обед, ужин) для конкретной даты — демо-данные
       static func meals(for date: Date) -> [String] {
           let wd = Calendar.app.component(.weekday, from: date) // 1=вс, 2=пн ...
           switch wd {
           case 2: return ["овсянка с бананом", "суп + тост", "паста с томатами"]
           case 3: return ["омлет с овощами", "салат + хлеб", "курица с рисом"]
           case 4: return ["творог с ягодами", "борщ", "рыба запечённая"]
           case 5: return ["панкейки", "гречка с грибами", "лапша удон"]
           case 6: return ["йогурт + мюсли", "цукини-крем суп", "плов"]
           case 7: return ["каша рисовая", "роллы домашние", "овощное рагу"]
           default: return ["бутерброды", "суп дня", "паста дня"]
           }
       }
}
