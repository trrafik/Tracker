import UIKit
import CoreData

final class TrackerRecordStore {

    private let context: NSManagedObjectContext

    convenience init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    /// Добавить запись о выполнении трекера на дату
    func addRecord(trackerId: UUID, date: Date) throws {
        let trackerRequest = TrackerCoreData.fetchRequest()
        trackerRequest.predicate = NSPredicate(format: "id == %@", trackerId as CVarArg)
        trackerRequest.fetchLimit = 1

        guard let tracker = try context.fetch(trackerRequest).first else { return }

        let record = TrackerRecordCoreData(context: context)
        record.date = date
        record.tracker = tracker
        try context.save()
    }

    /// Удалить запись о выполнении трекера на дату
    func removeRecord(trackerId: UUID, date: Date) throws {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "tracker.id == %@ AND date >= %@ AND date < %@",
            trackerId as CVarArg,
            startOfDay as NSDate,
            endOfDay as NSDate
        )

        let results = try context.fetch(request)
        results.forEach { context.delete($0) }
        try context.save()
    }

    /// Проверить, выполнён ли трекер на дату
    func isCompleted(trackerId: UUID, date: Date) throws -> Bool {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "tracker.id == %@ AND date >= %@ AND date < %@",
            trackerId as CVarArg,
            startOfDay as NSDate,
            endOfDay as NSDate
        )
        request.fetchLimit = 1

        let count = try context.count(for: request)
        return count > 0
    }

    /// Количество выполнений трекера (всего)
    func completedCount(trackerId: UUID) throws -> Int {
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "tracker.id == %@", trackerId as CVarArg)
        return try context.count(for: request)
    }

    /// Все записи (для отображения в UI без повторных запросов по дате)
    func allRecords() throws -> [TrackerRecord] {
        let request = TrackerRecordCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerRecordCoreData.date, ascending: false)]

        let results = try context.fetch(request)
        return results.compactMap { core -> TrackerRecord? in
            guard let tracker = core.tracker, let trackerId = tracker.id, let date = core.date else { return nil }
            return TrackerRecord(trackerId: trackerId, date: date)
        }
    }
}
