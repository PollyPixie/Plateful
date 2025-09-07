//
//  BackupManager.swift
//  Plateful
//
//  Created by Полина Соколова on 07.09.25.
//

import Foundation

struct BackupPayload: Codable {
    var version: Int = 1
    var createdAt: Date = Date()

    // MealStore
    var plans: [String: DayPlan]
    var availability: [String: [String]] // Set -> Array для JSON

    // BasketStore
    var basket: [BasketItem]

    // WeekStore
    var anchorMondayTS: TimeInterval
}

final class BackupManager {
    private let meals: MealStore
    private let basket: BasketStore
    private let week: WeekStore

    init(meals: MealStore, basket: BasketStore, week: WeekStore) {
        self.meals = meals
        self.basket = basket
        self.week  = week
    }

    // MARK: Export
    func makeExportData() throws -> Data {
        let (plans, avail) = meals.snapshot()
        let payload = BackupPayload(
            plans: plans,
            availability: avail.mapValues(Array.init),
            basket: basket.items,
            anchorMondayTS: week.anchorTimestamp()
        )
        let enc = JSONEncoder()
        enc.outputFormatting = [.prettyPrinted, .sortedKeys]
        enc.dateEncodingStrategy = .iso8601
        return try enc.encode(payload)
    }

    func exportToDocuments() throws -> URL {
        let data = try makeExportData()
        let fm = FileManager.default
        let docs = try fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let stamp = Self.timestamp()
        let url = docs.appendingPathComponent("Plateful-backup-\(stamp).json")
        try data.write(to: url, options: [.atomic])
        return url
    }

    // MARK: Import
    func importFromData(_ data: Data) throws {
        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .iso8601
        let payload = try dec.decode(BackupPayload.self, from: data)

        meals.replace(plans: payload.plans, availability: payload.availability.mapValues(Set.init))
        basket.replace(items: payload.basket)
        week.setAnchor(timestamp: payload.anchorMondayTS)
    }

    func importFromFile(_ url: URL) throws {
        try importFromData(Data(contentsOf: url))
    }

    private static func timestamp() -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone(secondsFromGMT: 0)
        df.dateFormat = "yyyyMMdd-HHmmss"
        return df.string(from: Date())
    }
}

// BackupManager.swift

extension BackupManager {
    static let latestFileName = "Plateful-backup-latest.json"
    static let prefix = "Plateful-backup-"
    static let ext = "json"

    /// Тихий экспорт: перезаписывает один «последний» файл в Documents
    @discardableResult
    func exportToLatest() throws -> URL {
        let data = try makeExportData()
        let docs = try FileManager.default.url(
            for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true
        )
        let url = docs.appendingPathComponent(Self.latestFileName)
        try data.write(to: url, options: [.atomic])
        return url
    }

    /// Найти самый свежий бэкап (по префиксу), если он есть
    static func latestBackupURL() throws -> URL? {
        let fm = FileManager.default
        let docs = try fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let files = try fm.contentsOfDirectory(
            at: docs,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: .skipsHiddenFiles
        )
        let candidates = files.filter { $0.lastPathComponent.hasPrefix(prefix) && $0.pathExtension == ext }
        guard !candidates.isEmpty else { return nil }
        let sorted = try candidates.sorted {
            let a = try $0.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate ?? .distantPast
            let b = try $1.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate ?? .distantPast
            return a > b
        }
        return sorted.first
    }

    /// Тихий импорт: подхватить последний бэкап
    func importLatestIfExists() throws {
        if let url = try Self.latestBackupURL() {
            try importFromFile(url)
        } else {
            throw NSError(domain: "Backup", code: 404,
                          userInfo: [NSLocalizedDescriptionKey: "No backup found"])
        }
    }
}
