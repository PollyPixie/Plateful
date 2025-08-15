//
//  MealsView.swift
//  Plateful
//
//  Created by Полина Соколова on 11.08.25.
//

import SwiftUI

struct MealsView: View {
    private let weekStore = WeekStore()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Заголовок недели
                Text(weekStore.weekTitle())
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .padding(.horizontal)

                Divider()

                // Дни текущей недели
                List(weekStore.daysOfCurrentWeek(), id: \.self) { day in
                    NavigationLink {
                        DayDetailView(date: day)  // <-- сюда уходим
                    } label: {
                        let dishes = MealData.meals(for: day)              // <-- новое
                        VStack(alignment: .leading, spacing: 6) {
                            Text(day.dayTitle())
                                .font(.headline)

                            Text(dishes.isEmpty
                                 ? "Завтрак • Обед • Ужин"
                                 : dishes.joined(separator: " • "))        // <-- новое
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Meals")
        }
    }
}


#Preview {
    MealsView()
}


