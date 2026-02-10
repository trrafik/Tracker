import UIKit
import CoreData

// Делегат FRC, перенаправляет обновления в замыкание (чтобы не экспортировать Core Data в контроллеры)
private final class FRCDelegate: NSObject, NSFetchedResultsControllerDelegate {
    private let onDidChange: () -> Void

    init(onDidChange: @escaping () -> Void) {
        self.onDidChange = onDidChange
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        onDidChange()
    }
}

final class TrackerStore {

    private let context: NSManagedObjectContext
    private let categoryStore: TrackerCategoryStore

    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCategoryCoreData.title, ascending: true)]
        request.relationshipKeyPathsForPrefetching = ["trackers"]

        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = frcDelegate
        return controller
    }()

    private lazy var frcDelegate = FRCDelegate { [weak self] in
        self?.onCategoriesDidChange?()
    }

    // Вызывается при изменении данных в Core Data (через NSFetchedResultsController)
    var onCategoriesDidChange: (() -> Void)?

    convenience init() {
        let context = DataBaseStore.shared.persistentContainer.viewContext
        let categoryStore = TrackerCategoryStore(context: context)
        self.init(context: context, categoryStore: categoryStore)
    }

    init(context: NSManagedObjectContext, categoryStore: TrackerCategoryStore) {
        self.context = context
        self.categoryStore = categoryStore
    }

    // Выполнить начальную загрузку данных для FRC
    func performFetch() throws {
        try fetchedResultsController.performFetch()
    }

    // Преобразование результатов FRC в доменные категории
    func categoriesFromFetchedResults() -> [TrackerCategory] {
        guard let categories = fetchedResultsController.fetchedObjects else { return [] }
        return categories.map { categoryCore in
            let trackers = (categoryCore.trackers as? Set<TrackerCoreData> ?? [])
                .sorted { ($0.name ?? "") < ($1.name ?? "") }
                .compactMap { tracker(from: $0) }
            return TrackerCategory(title: categoryCore.title ?? "", trackers: trackers)
        }
    }

    func add(_ tracker: Tracker) throws {
        let category = try categoryStore.defaultCategory()

        let core = TrackerCoreData(context: context)
        core.id = tracker.id
        core.name = tracker.name
        core.emoji = tracker.emoji
        core.color = UIColorMarshalling.hexString(from: tracker.color)
        core.schedule = tracker.schedule.map { String($0.rawValue) }.joined(separator: ",")
        core.category = category

        try context.save()
    }

    func tracker(from core: TrackerCoreData) -> Tracker? {
        guard let id = core.id,
              let name = core.name,
              let emoji = core.emoji else { return nil }

        let color: UIColor = core.color.flatMap { UIColorMarshalling.color(from: $0) } ?? .systemGreen

        let schedule: [Tracker.Weekday] = (core.schedule ?? "")
            .split(separator: ",")
            .compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
            .compactMap { Tracker.Weekday(rawValue: $0) }

        return Tracker(
            id: id,
            name: name,
            color: color,
            emoji: emoji,
            schedule: schedule
        )
    }
}
