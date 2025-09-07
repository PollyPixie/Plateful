//
//  MealsView.swift
//  Plateful
//
//  Created by Полина Соколова on 11.08.25.
//

import SwiftUI

struct MealsView: View {
    @EnvironmentObject var mealStore: MealStore        // ← добавили
    private let weekStore = WeekStore()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Text(weekStore.weekTitle())
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .padding(.horizontal)

                Divider()

                List(weekStore.daysOfCurrentWeek(), id: \.self) { day in
                    NavigationLink {
                        DayDetailView(date: day)
                    } label: {
                        let plan = mealStore.plan(for: day)              // ← из MealStore
                        let dishes = [plan.breakfast, plan.lunch, plan.dinner]
                            .filter { !$0.isEmpty }
                            .joined(separator: " • ")

                        VStack(alignment: .leading, spacing: 6) {
                            Text(day.dayTitle())
                                .font(.headline)
                            Text(dishes.isEmpty ? "Завтрак • Обед • Ужин" : dishes)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Рацион")
        }
    }
}



#Preview {
    MealsView()
}


