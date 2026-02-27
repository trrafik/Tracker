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
            case .monday: return NSLocalizedString("weekday.short.mon", comment: "")
            case .tuesday: return NSLocalizedString("weekday.short.tue", comment: "")
            case .wednesday: return NSLocalizedString("weekday.short.wed", comment: "")
            case .thursday: return NSLocalizedString("weekday.short.thu", comment: "")
            case .friday: return NSLocalizedString("weekday.short.fri", comment: "")
            case .saturday: return NSLocalizedString("weekday.short.sat", comment: "")
            case .sunday: return NSLocalizedString("weekday.short.sun", comment: "")
            }
        }
        
        var fullName: String {
            switch self {
            case .monday: return NSLocalizedString("weekday.full.monday", comment: "")
            case .tuesday: return NSLocalizedString("weekday.full.tuesday", comment: "")
            case .wednesday: return NSLocalizedString("weekday.full.wednesday", comment: "")
            case .thursday: return NSLocalizedString("weekday.full.thursday", comment: "")
            case .friday: return NSLocalizedString("weekday.full.friday", comment: "")
            case .saturday: return NSLocalizedString("weekday.full.saturday", comment: "")
            case .sunday: return NSLocalizedString("weekday.full.sunday", comment: "")
            }
        }
    }
}

extension Array where Element == Tracker.Weekday {
    func formattedSchedule() -> String {
        if isEmpty {
            return ""
        } else if count == 7 {
            return NSLocalizedString("weekday.everyDay", comment: "")
        } else {
            return map { $0.shortName }.joined(separator: ", ")
        }
    }
}
