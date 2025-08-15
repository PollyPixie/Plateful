//
//  DayDetailView.swift
//  Plateful
//
//  Created by Полина Соколова on 14.08.25.
//

import SwiftUI

struct DayDetailView: View {
    let date: Date
    @EnvironmentObject var basket: BasketStore
    
    @State private var available: [String: Bool] = [:] // имя → есть/нет (только для UI)

    // Пока просто пример. Позже подставим реальные данные из модели меню.
    var ingredients: [String] {
        MealData.ingredients(for: date)
    }

    var body: some View {
        List {
            Section("Меню (демо)") {
                let meals = MealData.meals(for: date)
                if meals.count >= 3 {
                    Text("Завтрак: \(meals[0])")
                    Text("Обед: \(meals[1])")
                    Text("Ужин: \(meals[2])")
                }
            }

            Section("ИНГРЕДИЕНТЫ") {
                ForEach(ingredients, id: \.self) { name in
                    let isAvailable = available[name] ?? false

                    HStack(spacing: 12) {
                        // Галочка «есть/нет»
                        Button {
                            available[name] = !(available[name] ?? false)
                        } label: {
                            Image(systemName: isAvailable ? "checkmark.circle.fill" : "circle")
                                .imageScale(.large)
                                .foregroundStyle(isAvailable ? Color.brandOlive : .secondary)
                        }
                        .buttonStyle(.plain)

                        // Название
                        Text(name)
                            .lineLimit(1)
                            .strikethrough(isAvailable, color: .gray)
                            .foregroundStyle(isAvailable ? .secondary : .primary)

                        Spacer(minLength: 12)

                        // Квадратная кнопка корзины без текста
                        SquareIconButton(systemName: "cart.badge.plus") {
                            basket.add(name)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }


        }
        .navigationTitle(date.dayTitle()) // у тебя уже есть удобный форматер в DateExtensions
    }
    
    private struct SquareIconButton: View {
        let systemName: String
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Image(systemName: systemName)
                    .imageScale(.medium)
                    .frame(width: 34, height: 34)                  // квадрат
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.roundedRectangle(radius: 8))       // мягкие углы
            .tint(.brandOlive)                                     // твой фирменный цвет
        }
    }
}
