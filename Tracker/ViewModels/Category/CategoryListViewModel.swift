import Foundation

/// ViewModel экрана списка категорий.
final class CategoryListViewModel {

    // MARK: - Bindings

    var onCategoriesDidChange: (() -> Void)?
    var onSelectionDidChange: ((String) -> Void)?
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

    // MARK: - Данные для таблицы (свойства)

    var rowsAmount: Int {
        categories.count
    }

    var isEmpty: Bool {
        categories.isEmpty
    }

    // MARK: - Данные для таблицы (по индексу)

    func categoryTitle(at index: Int) -> String? {
        guard index >= 0, index < categories.count else { return nil }
        return categories[index].title
    }

    func isSelected(at index: Int) -> Bool {
        guard let title = categoryTitle(at: index) else { return false }
        return title == selectedCategoryTitle
    }

    // MARK: - Действия

    func loadCategories() {
        do {
            categories = try categoryStore.fetchAllCategories()
            onCategoriesDidChange?()
        } catch {
            categories = []
            onCategoriesDidChange?()
        }
    }

    func selectCategory(at index: Int) {
        guard let title = categoryTitle(at: index) else { return }
        let previousIndex = categories.firstIndex { $0.title == selectedCategoryTitle }
        selectedCategoryTitle = title
        onSelectionDidChange?(title)
        onSelectionIndexDidChange?(previousIndex, index)
    }
}
