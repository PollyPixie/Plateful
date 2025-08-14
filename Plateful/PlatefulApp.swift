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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(basket) // теперь любая вью ниже может читать/менять корзину
        }
    }
}

