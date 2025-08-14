//
//  ContentView.swift
//  Plateful
//
//  Created by Полина Соколова on 11.08.25.
//

// ContentView.swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            MealsView()
                .tabItem {
                    Image(systemName: "fork.knife")
                    Text("Meals")
                }

            BasketView()
                .tabItem {
                    Image(systemName: "cart")
                    Text("Basket")
                }

            CalendarView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendar")
                }
        }
        .tint(.brandOlive) // цвет активной вкладки и системных акцентов
    }
}

#Preview {
    ContentView()
}
