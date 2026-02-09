import UIKit
import CoreData

final class TrackerCategoryStore {

    /// Категория по умолчанию для новых привычек (пока выбор категорий не реализован)
    static let defaultCategoryTitle = "Привычки"

    private let context: NSManagedObjectContext

    convenience init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    /// Возвращает категорию по умолчанию (создаётся в БД при первом обращении)
    func defaultCategory() throws -> TrackerCategoryCoreData {
        try category(withTitle: Self.defaultCategoryTitle)
    }

    /// Возвращает существующую категорию по названию или создаёт новую
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
}
