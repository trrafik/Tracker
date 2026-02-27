import Foundation

/// Сервис для работы с UserDefaults. Централизует ключи и типизирует доступ.
final class UserDefaultsService {
    
    static let shared = UserDefaultsService()
    private let defaults = UserDefaults.standard
    
    private init() {}
    
    private enum Key {
        static let onboardingCompleted = "onboardingCompleted"
        static let trackerFilter = "trackerFilter"
    }
    
    var isOnboardingCompleted: Bool {
        get { defaults.bool(forKey: Key.onboardingCompleted) }
        set { defaults.set(newValue, forKey: Key.onboardingCompleted) }
    }
    
    /// Текущий выбранный фильтр трекеров. По умолчанию — «Все трекеры».
    var trackerFilter: TrackerFilter {
        get {
            let raw = defaults.integer(forKey: Key.trackerFilter)
            return TrackerFilter(rawValue: raw) ?? .all
        }
        set { defaults.set(newValue.rawValue, forKey: Key.trackerFilter) }
    }
}
