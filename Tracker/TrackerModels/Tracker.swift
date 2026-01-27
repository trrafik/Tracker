import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [Weekday]
    
    enum Weekday: Int, CaseIterable {
        case monday = 1
        case tuesday = 2
        case wednesday = 3
        case thursday = 4
        case friday = 5
        case saturday = 6
        case sunday = 7
        
        var shortName: String {
            switch self {
            case .monday: return "Пн"
            case .tuesday: return "Вт"
            case .wednesday: return "Ср"
            case .thursday: return "Чт"
            case .friday: return "Пт"
            case .saturday: return "Сб"
            case .sunday: return "Вс"
            }
        }
        
        var fullName: String {
            switch self {
            case .monday: return "Понедельник"
            case .tuesday: return "Вторник"
            case .wednesday: return "Среда"
            case .thursday: return "Четверг"
            case .friday: return "Пятница"
            case .saturday: return "Суббота"
            case .sunday: return "Воскресенье"
            }
        }
    }
}

extension Array where Element == Tracker.Weekday {
    func formattedSchedule() -> String {
        if isEmpty {
            return ""
        } else if count == 7 {
            return "Каждый день"
        } else {
            return map { $0.shortName }.joined(separator: ", ")
        }
    }
}
