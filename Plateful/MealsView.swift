//
//  MealsView.swift
//  Plateful
//
//  Created by Полина Соколова on 11.08.25.
//

import SwiftUI

struct MealsView: View {
    @EnvironmentObject var mealStore: MealStore
    @EnvironmentObject var basket: BasketStore
    private let weekStore = WeekStore()

    // алерты об успехе/ошибке
    @State private var showAlert = false
    @State private var alertText = ""

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
                        let plan = mealStore.plan(for: day)
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
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    // S I L E N T  E X P O R T
                    Button {
                        let manager = BackupManager(meals: mealStore, basket: basket, week: weekStore)
                        do {
                            try manager.exportToLatest()
                            alertText = "Бэкап сохранён"
                            showAlert = true
                        } catch {
                            alertText = "Ошибка экспорта: \(error.localizedDescription)"
                            showAlert = true
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }

                    // S I L E N T  I M P O R T
                    Button {
                        let manager = BackupManager(meals: mealStore, basket: basket, week: weekStore)
                        do {
                            try manager.importLatestIfExists()
                            alertText = "Бэкап восстановлен"
                            showAlert = true
                        } catch {
                            alertText = "Ошибка импорта: \(error.localizedDescription)"
                            showAlert = true
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.down")
                    }
                }
            }
            .alert(alertText, isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            }
        }
    }
}

#Preview {
    MealsView()
        .environmentObject(MealStore())
        .environmentObject(BasketStore())
}




