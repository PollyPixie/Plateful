//
//  ContentView.swift
//  Plateful
//
//  Created by Полина Соколова on 11.08.25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            MealsView()
                .tabItem {
                    Image(systemName: "fork.knife")
                    Text("Рацион")
                }

            BasketView()
                .tabItem {
                    Image(systemName: "cart")
                    Text("Корзина")
                }

            CalendarView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Календарь")
                }
        }
        .tint(.brandOlive) // цвет активной вкладки и системных акцентов
    }
}

#Preview {
    ContentView()
}
