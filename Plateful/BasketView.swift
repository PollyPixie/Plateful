//
//  BasketView.swift
//  Plateful
//
//  Created by Полина Соколова on 11.08.25.
//

import SwiftUI

struct BasketView: View {
    @EnvironmentObject var basket: BasketStore
    @State private var newItem = ""

    // Собственная «ручка» редактирования
    @State private var isEditing = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                // ... твой TextField и остальное

                if basket.items.isEmpty {
                    // ... пустое состояние
                } else {
                    List {
                        ForEach(basket.items) { item in
                            HStack {
                                Text(item.name)
                                Spacer()
                                Text("×\(item.quantity)")
                                    .monospacedDigit()
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .onDelete(perform: basket.remove)
                        .onMove(perform: basket.move)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Корзина")
            .toolbar {
                if !basket.items.isEmpty {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        // Кнопка на русском
                        Button(isEditing ? "Готово" : "Изменить") {
                            withAnimation { isEditing.toggle() }
                        }
                        Button("Очистить", role: .destructive, action: basket.clear)
                    }
                }
            }
        }
        // ВАЖНО: прокинуть состояние редактирования в окружение списка
        .environment(\.editMode, .constant(isEditing ? .active : .inactive))
    }
}



