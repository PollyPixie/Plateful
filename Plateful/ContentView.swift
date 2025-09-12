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
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var weekStore: WeekStore

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
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                let manager = BackupManager(meals: mealStore, basket: basket, week: weekStore)
                _ = try? manager.exportToLatest()
            }
        }
    }
}

#Preview {
    ContentView()
}
