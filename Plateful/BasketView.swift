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

    // Реальный edit-mode, который передаём в окружение как binding
    @State private var editMode: EditMode = .inactive

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                // Ввод новой позиции вручную
                HStack(spacing: 8) {
                    TextField("Новый продукт", text: $newItem)
                        .textFieldStyle(.roundedBorder)
                    Button {
                        basket.add(newItem)
                        newItem = ""
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .imageScale(.large)
                    }
                    .disabled(newItem.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal)

                // Список корзины
                if basket.items.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "cart")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                        Text("Пока пусто")
                            .foregroundStyle(.secondary)
                        Text("Добавляй вручную или из меню дня")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 40)
                } else {
                    List {
                        ForEach(basket.items) { item in
                            HStack {
                                Text(item.name)

                                Spacer()

                                // Освобождаем место под «гребёнку» перетаскивания (она справа)
                                if editMode != .active {
                                    Text("×\(item.quantity)")
                                        .monospacedDigit()
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .onDelete(perform: basket.remove)
                        .onMove(perform: basket.move) // перетаскивание строк в edit-режиме
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Корзина")
            .toolbar {
                if !basket.items.isEmpty {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button(editMode == .active ? "Готово" : "Изменить") {
                            withAnimation {
                                editMode = (editMode == .active) ? .inactive : .active
                            }
                        }
                        Button("Очистить", role: .destructive, action: basket.clear)
                    }
                }
            }
        }
        // Ключ: передаём живой binding editMode, чтобы List включал режим редактирования
        .environment(\.editMode, $editMode)
    }
}




