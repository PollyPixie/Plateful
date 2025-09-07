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

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                // Ввод новой позиции вручную
                HStack(spacing: 8) {
                    TextField("Новый ингредиент", text: $newItem)
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
                                Text("×\(item.quantity)")
                                    .monospacedDigit()
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .onDelete(perform: basket.remove)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Корзина")
            .toolbar {
                if !basket.items.isEmpty {
                    Button("Очистить", role: .destructive, action: basket.clear)
                }
            }
        }
    }
}


