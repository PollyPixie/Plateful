//
//  BasketStore.swift
//  Plateful
//
//  Created by Полина Соколова on 14.08.25.
//

import Foundation

struct BasketItem: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var quantity: Int

    init(name: String, quantity: Int = 1, id: UUID = UUID()) {
        self.id = id
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.quantity = max(1, quantity)
    }
}

/// Хранилище корзины (наблюдаемая модель)
final class BasketStore: ObservableObject {
    @Published var items: [BasketItem] = [] {
        didSet { save() } // при любом изменении сразу сохраняем
    }

    private let storageKey = "basket.items.v1"

    init() { load() }

    // Добавить позицию (если уже есть – увеличиваем количество)
    func add(_ name: String) {
        let key = name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty else { return }
        if let i = items.firstIndex(where: { $0.name.lowercased() == key }) {
            items[i].quantity += 1
        } else {
            items.append(BasketItem(name: name))
        }
    }

    func remove(at offsets: IndexSet) { items.remove(atOffsets: offsets) }
    func clear() { items.removeAll() }

    // MARK: - Persistence (UserDefaults + JSON)
    private func save() {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode([BasketItem].self, from: data)
        else { return }
        items = decoded
    }
}
