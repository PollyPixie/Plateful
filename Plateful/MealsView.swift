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
    @EnvironmentObject var weekStore: WeekStore

    // алерты об успехе/ошибке
    @State private var showAlert = false
    @State private var alertText = ""

    // -1 ← предыдущая | 0 текущая | +1 следующая
    @State private var weekOffset: Int = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // Заголовок недели со стрелками
                HStack(spacing: 12) {
                    Button {
                        if weekOffset > -1 { weekOffset -= 1 }
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                    .disabled(weekOffset <= -1)

                    Text(weekStore.weekTitle(offset: weekOffset))
                        .font(.headline)
                        .frame(maxWidth: .infinity)

                    Button {
                        if weekOffset < 1 { weekOffset += 1 }
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                    .disabled(weekOffset >= 1)
                }
                .padding(.vertical, 8)
                .padding(.horizontal)

                Divider()

                // Список дней выбранной недели
                List(weekStore.daysOfWeek(offset: weekOffset), id: \.self) { day in
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
            // Всегда возвращаемся к текущей неделе
            .onAppear { weekOffset = 0 }
            .onChange(of: weekStore.anchorMonday) { _, _ in
                weekOffset = 0
            }
        }
    }
}

#Preview {
    MealsView()
        .environmentObject(MealStore())
        .environmentObject(BasketStore())
        .environmentObject(WeekStore())
}





