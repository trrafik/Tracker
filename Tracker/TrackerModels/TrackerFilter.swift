import Foundation

/// Варианты фильтрации трекеров на главном экране.
enum TrackerFilter: Int, CaseIterable {
    case all = 0
    case today = 1
    case completed = 2
    case uncompleted = 3

    var title: String {
        switch self {
        case .all: return NSLocalizedString("filter.all", comment: "")
        case .today: return NSLocalizedString("filter.today", comment: "")
        case .completed: return NSLocalizedString("filter.completed", comment: "")
        case .uncompleted: return NSLocalizedString("filter.uncompleted", comment: "")
        }
    }

    /// Нужно ли показывать синюю галочку в списке фильтров (для «Все трекеры» и «Трекеры на сегодня» — нет).
    var showsCheckmarkWhenSelected: Bool {
        switch self {
        case .all, .today: return false
        case .completed, .uncompleted: return true
        }
    }
}
