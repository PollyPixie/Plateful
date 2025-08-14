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

    // Пока просто пример. Позже подставим реальные данные из модели меню.
    var ingredients: [String] {
        MealData.ingredients(for: date)
    }

    var body: some View {
        List {
            Section("Меню (демо)") {
                Text("Завтрак: овсянка с бананом")
                Text("Обед: суп + тост")
                Text("Ужин: паста с томатами")
            }

            Section("Ингредиенты") {
                ForEach(ingredients, id: \.self) { name in
                    HStack {
                        Text(name)
                        Spacer()
                        Button {
                            basket.add(name)
                        } label: {
                            Label("В корзину", systemImage: "cart.badge.plus")
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
        }
        .navigationTitle(date.dayTitle()) // у тебя уже есть удобный форматер в DateExtensions
    }
}
