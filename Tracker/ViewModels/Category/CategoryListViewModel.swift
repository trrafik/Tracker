import Foundation

//ViewModel экрана списка категорий готовит данные для ячеек и обрабатывает действия пользователя.
final class CategoryListViewModel {

    // MARK: - Bindings
    
    // Вызывается при изменении списка категорий — обновить таблицу
    var onCategoriesDidChange: (() -> Void)?

    // Вызывается при выборе категории — передаётся выбранное название
    var onSelectionDidChange: ((String) -> Void)?

    // Вызывается при смене выбора
    var onSelectionIndexDidChange: ((Int?, Int) -> Void)?

    // MARK: - Private

    private let categoryStore: TrackerCategoryStore
    private var categories: [TrackerCategory] = []
    private(set) var selectedCategoryTitle: String?

    // MARK: - Init

    init(categoryStore: TrackerCategoryStore = TrackerCategoryStore(), selectedCategoryTitle: String?) {
        self.categoryStore = categoryStore
        self.selectedCategoryTitle = selectedCategoryTitle
    }

    // MARK: - Данные для таблицы (получение из модели, подготовка для ячеек)

    // Загрузить категории из модели и уведомить View
    func loadCategories() {
        do {
            categories = try categoryStore.fetchAllCategories()
            onCategoriesDidChange?()
        } catch {
            categories = []
            onCategoriesDidChange?()
        }
    }

    func numberOfRows() -> Int {
        categories.count
    }

    func categoryTitle(at index: Int) -> String? {
        guard index >= 0, index < categories.count else { return nil }
        return categories[index].title
    }

    func isSelected(at index: Int) -> Bool {
        guard let title = categoryTitle(at: index) else { return false }
        return title == selectedCategoryTitle
    }

    // MARK: - Обработка действий пользователя

    func selectCategory(at index: Int) {
        guard let title = categoryTitle(at: index) else { return }
        let previousIndex = categories.firstIndex { $0.title == selectedCategoryTitle }
        selectedCategoryTitle = title
        onSelectionDidChange?(title)
        onSelectionIndexDidChange?(previousIndex, index)
    }

    var isEmpty: Bool {
        categories.isEmpty
    }
}
