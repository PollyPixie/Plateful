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
    @EnvironmentObject var mealStore: MealStore

    // MARK: - State (UI)
    @State private var rowToast: [String: Bool] = [:]
    @State private var newIngredient = ""

    // Локальная копия плана для биндингов текстовых полей
    @State private var plan: DayPlan = .init(breakfast: "", lunch: "", dinner: "", ingredients: [])

    // MARK: - Body
    var body: some View {
        List {
            // Меню — редактируем
            Section("Меню") {
                TextField("Завтрак", text: $plan.breakfast)
                    .textInputAutocapitalization(.sentences)
                TextField("Обед",     text: $plan.lunch)
                    .textInputAutocapitalization(.sentences)
                TextField("Ужин",     text: $plan.dinner)
                    .textInputAutocapitalization(.sentences)
            }

            // Ингредиенты — добавление
            Section("ИНГРЕДИЕНТЫ") {
                HStack(spacing: 8) {
                    TextField("Новый ингредиент", text: $newIngredient)
                        .textFieldStyle(.roundedBorder)
                    // Квадратная кнопка добавления
                    SquareIconButton(systemName: "plus") {
                        mealStore.addIngredient(newIngredient, to: date)
                        newIngredient = ""
                        // Обновим локальное состояние, чтобы список тут же обновился
                        plan = mealStore.plan(for: date)
                    }
                    .disabled(newIngredient.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                // Ингредиенты — список с галочками и удалением свайпом
                ForEach(plan.ingredients, id: \.self) { name in
                    let isAvailable = mealStore.isHave(name, on: date)

                    HStack(spacing: 12) {
                        // Галочка «есть/нет» — теперь из стора
                        Button {
                            mealStore.toggleHave(name, on: date)
                        } label: {
                            Image(systemName: isAvailable ? "checkmark.circle.fill" : "circle")
                                .imageScale(.large)
                                .foregroundStyle(isAvailable ? Color.brandOlive : .secondary)
                        }
                        .buttonStyle(.plain)
                       

                        Text(name)
                            .lineLimit(1)
                            .strikethrough(isAvailable, color: .gray)
                            .foregroundStyle(isAvailable ? .secondary : .primary)

                        Spacer(minLength: 12)

                        SquareIconButton(systemName: "cart.badge.plus") {
                            basket.add(name)
                            showRowToast(for: name)
                        }
                    }
                    .padding(.vertical, 4)
                    .overlay(alignment: .trailing) {
                        if rowToast[name] == true {
                            Text("Добавлено")
                                .font(.callout).bold()
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Capsule().fill(Color.brandOlive))
                                .foregroundColor(.brandOnOlive)
                                .padding(.trailing, 44)
                                .transition(.opacity)
                                .opacity(1)
                                .allowsHitTesting(false)
                                .zIndex(1)
                        }
                    }
                }
                .onDelete { offsets in                      // ← удаление ингредиентов
                    mealStore.removeIngredients(at: offsets, for: date)
                    plan = mealStore.plan(for: date)
                }
            }
        }
        .navigationTitle(date.dayTitle())
        // Подтягиваем план при появлении и при возврате на экран
        .onAppear { plan = mealStore.plan(for: date) }
        // Любое изменение полей — сразу сохраняем
        .onChange(of: plan, initial: false) {
            mealStore.update(plan, for: date)
        }
    }

    // MARK: - Toast Logic (как у тебя)
    private func showRowToast(for name: String) {
        withAnimation(.easeInOut(duration: 0.15)) { rowToast[name] = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeInOut(duration: 0.2)) { rowToast[name] = false }
        }
    }

    // MARK: - Кнопка (твоя, без изменений)
    private struct SquareIconButton: View {
        let systemName: String
        let action: () -> Void
        @State private var pressed = false
        @State private var pulse = false
        @State private var bounce = false
        var body: some View {
            Button {
                action()
                withAnimation(.spring(response: 0.12, dampingFraction: 0.55)) {
                    pressed = true; bounce.toggle(); pulse.toggle()
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
                    .symbolEffect(.bounce, value: bounce)
                    .background(
                        Circle()
                            .fill(Color.brandOlive.opacity(pulse ? 0.0 : 0.35))
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



