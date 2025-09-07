//
//  PlatefulApp.swift
//  Plateful
//
//  Created by Полина Соколова on 11.08.25.
//

import SwiftUI

@main
struct PlatefulApp: App {
    // Один «живой» экземпляр корзины на всё приложение
    @StateObject private var basket = BasketStore()
    @StateObject private var meals = MealStore()

    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()

        // МЕНЬШЕ обычного largeTitle (~34pt)
        let large = UIFont.systemFont(ofSize: 26, weight: .semibold)
        let inline = UIFont.systemFont(ofSize: 17, weight: .semibold)

        // Если хочешь уважать Dynamic Type:
        let largeScaled = UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: large)
        let inlineScaled = UIFontMetrics(forTextStyle: .headline).scaledFont(for: inline)

        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.secondaryLabel,
            .font: largeScaled
        ]
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.secondaryLabel,
            .font: inlineScaled
        ]

        let navBar = UINavigationBar.appearance()
        navBar.standardAppearance   = appearance
        navBar.scrollEdgeAppearance = appearance
        navBar.compactAppearance    = appearance
       }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(basket)
                .environmentObject(meals)
        }
    }
}

