import UIKit
import CoreData

/// Хранилище категорий трекеров поверх Core Data.
final class TrackerCategoryStore {

    private let context: NSManagedObjectContext

    convenience init() {
        let context = DataBaseStore.shared.persistentContainer.viewContext
        self.init(context: context)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func category(withTitle title: String) throws -> TrackerCategoryCoreData {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.title), title)
        request.fetchLimit = 1

        let results = try context.fetch(request)
        if let existing = results.first {
            return existing
        }

        let category = TrackerCategoryCoreData(context: context)
        category.title = title
        try context.save()
        return category
    }

    func fetchAllCategories() throws -> [TrackerCategory] {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCategoryCoreData.title, ascending: true)]
        let results = try context.fetch(request)
        return results.map { core in
            TrackerCategory(title: core.title ?? "", trackers: [])
        }
    }
}
