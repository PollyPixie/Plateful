//
//  ContentView.swift
//  Plateful
//
//  Created by Полина Соколова on 11.08.25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var mealStore: MealStore
    @EnvironmentObject var basket: BasketStore
    @EnvironmentObject var weekStore: WeekStore
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        TabView {
            MealsView()
                .tabItem { Image(systemName: "fork.knife"); Text("Рацион") }

            BasketView()
                .tabItem { Image(systemName: "cart"); Text("Корзина") }

            CalendarView()
                .tabItem { Image(systemName: "calendar"); Text("Календарь") }
        }
        .tint(.brandOlive)

        // 1) Возврат приложения в активность → проверить, не наступила ли новая неделя
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                weekStore.ensureCurrentWeek()
            }
            if newPhase == .background {
                // существующий бэкап при сворачивании
                let manager = BackupManager(meals: mealStore, basket: basket, week: weekStore)
                _ = try? manager.exportToLatest()
            }
        }

        // 2) Смена календарного дня в системе → лениво обновить якорь
        .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in
            weekStore.ensureCurrentWeek()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(MealStore())
        .environmentObject(BasketStore())
        .environmentObject(WeekStore())
}
