//
//  DayDetailView.swift
//  Plateful
//
//  Created by Полина Соколова on 14.08.25.
//

import SwiftUI

struct DayDetailView: View {
    let date: Date
    @EnvironmentObject var basket: BasketStore

    // MARK: - State
    @State private var available: [String: Bool] = [:]     // имя → есть/нет (только для UI)
    @State private var rowToast: [String: Bool] = [:]       // имя → виден ли тост для этой строки

    // MARK: - Data
    var ingredients: [String] { MealData.ingredients(for: date) }

    // MARK: - Body
    var body: some View {
        List {
            // Меню
            Section("Меню (демо)") {
                let meals = MealData.meals(for: date)
                if meals.count >= 3 {
                    Text("Завтрак: \(meals[0])")
                    Text("Обед: \(meals[1])")
                    Text("Ужин: \(meals[2])")
                }
            }

            // Ингредиенты
            Section("ИНГРЕДИЕНТЫ") {
                ForEach(ingredients, id: \.self) { name in
                    let isAvailable = available[name] ?? false

                    HStack(spacing: 12) {
                        // Галочка «есть/нет»
                        Button {
                            available[name] = !(available[name] ?? false)
                        } label: {
                            Image(systemName: isAvailable ? "checkmark.circle.fill" : "circle")
                                .imageScale(.large)
                                .foregroundStyle(isAvailable ? Color.brandOlive : .secondary)
                        }
                        .buttonStyle(.plain)

                        // Название
                        Text(name)
                            .lineLimit(1)
                            .strikethrough(isAvailable, color: .gray)
                            .foregroundStyle(isAvailable ? .secondary : .primary)

                        Spacer(minLength: 12)

                        // Кнопка корзины
                        SquareIconButton(systemName: "cart.badge.plus") {
                            basket.add(name)
                            showRowToast(for: name)
                        }
                    }
                    .padding(.vertical, 4)

                    // Тост для этой строки (справа, без сдвига layout'а)
                    .overlay(alignment: .trailing) {
                        if rowToast[name] == true {
                            Text("Добавлено")
                                .font(.callout).bold()                 // крупнее и читаемее
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Capsule().fill(Color.brandOlive))
                                .foregroundColor(.brandOnOlive)
                                .padding(.trailing, 44)                // держим место для кнопки корзины
                                .offset(y: -2)                         // лёгкая вертикальная правка (по вкусу)
                                .transition(.opacity)                  // просто проявление/затухание
                                .opacity(1)
                                .allowsHitTesting(false)
                                .zIndex(1)
                        }
                    }

                }
            }
        }
        .navigationTitle(date.dayTitle())
    }

    // MARK: - Toast Logic
    private func showRowToast(for name: String) {
        withAnimation(.easeInOut(duration: 0.15)) {
            rowToast[name] = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeInOut(duration: 0.2)) {
                rowToast[name] = false
            }
        }
    }

    // MARK: - SquareIconButton
    private struct SquareIconButton: View {
        let systemName: String
        let action: () -> Void

        @State private var pressed = false
        @State private var pulse = false   // всплеск под иконкой
        @State private var bounce = false  // подпрыгивание символа

        var body: some View {
            Button {
                action()

                // «смачное» нажатие
                withAnimation(.spring(response: 0.12, dampingFraction: 0.55)) {
                    pressed = true
                    bounce.toggle()
                    pulse.toggle()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                    withAnimation(.spring(response: 0.22, dampingFraction: 0.75)) {
                        pressed = false
                    }
                }
            } label: {
                Image(systemName: systemName)
                    .imageScale(.medium)
                    .frame(width: 34, height: 34)
                    .symbolEffect(.bounce, value: bounce) // iOS 17+
                    .background(
                        Circle()
                            .fill(Color.brandOlive.opacity(pulse ? 0.0 : 0.35)) // затухающий всплеск
                            .scaleEffect(pulse ? 1.6 : 0.01)
                            .animation(.easeOut(duration: 0.28), value: pulse)
                    )
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.roundedRectangle(radius: 8))
            .tint(.brandOlive)
            .scaleEffect(pressed ? 0.78 : 1.0)
            .opacity(pressed ? 0.75 : 1.0)
        }
    }
}


