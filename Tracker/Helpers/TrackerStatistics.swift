import Foundation

/// Расчёт показателей статистики по записям и списку трекеров.
enum TrackerStatistics {

    struct Result {
        let bestPeriod: Int
        let idealDays: Int
        let completed: Int
        let average: Int
    }

    static func compute(records: [TrackerRecord], trackers: [Tracker]) -> Result {
        Result(
            bestPeriod: bestPeriod(records: records),
            idealDays: idealDays(records: records, trackers: trackers),
            completed: records.count,
            average: average(records: records)
        )
    }

    /// Длина самой длинной серии подряд идущих дней с хотя бы одним завершением.
    private static func bestPeriod(records: [TrackerRecord]) -> Int {
        let calendar = Calendar.current
        
        let uniqueDays = Set(records.map {
            calendar.startOfDay(for: $0.date)
        }).sorted()
        
        guard !uniqueDays.isEmpty else { return 0 }
        
        var longestStreak = 1
        var currentStreak = 1
        
        for (previous, current) in zip(uniqueDays, uniqueDays.dropFirst()) {
            let difference = calendar.dateComponents([.day], from: previous, to: current).day ?? 0
            
            if difference == 1 {
                currentStreak += 1
            } else {
                longestStreak = max(longestStreak, currentStreak)
                currentStreak = 1
            }
        }
        
        return max(longestStreak, currentStreak)
    }

    /// Дни, в которые все запланированные на этот день трекеры были завершены.
    private static func idealDays(
        records: [TrackerRecord],
        trackers: [Tracker]
    ) -> Int {
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let recordsByDay = groupRecordsByDay(records, calendar: calendar)
        
        return recordsByDay.filter { day, completedTrackerIds in
            guard day <= today else { return false }
            
            let weekday = weekday(for: day, calendar: calendar)
            let scheduledIds = scheduledTrackerIds(for: weekday, trackers: trackers)
            
            return !scheduledIds.isEmpty &&
                   scheduledIds.isSubset(of: completedTrackerIds)
            
        }.count
    }
    
    private static func groupRecordsByDay(
        _ records: [TrackerRecord],
        calendar: Calendar
    ) -> [Date: Set<UUID>] {
        
        Dictionary(grouping: records) {
            calendar.startOfDay(for: $0.date)
        }
        .mapValues { Set($0.map(\.trackerId)) }
    }
    
    private static func weekday(
        for date: Date,
        calendar: Calendar
    ) -> Tracker.Weekday {
        
        let systemWeekday = calendar.component(.weekday, from: date)
        
        return systemWeekday == 1
            ? .sunday
            : Tracker.Weekday(rawValue: systemWeekday - 1) ?? .monday
    }
    
    private static func scheduledTrackerIds(
        for weekday: Tracker.Weekday,
        trackers: [Tracker]
    ) -> Set<UUID> {
        
        Set(
            trackers
                .filter { $0.schedule.isEmpty || $0.schedule.contains(weekday) }
                .map(\.id)
        )
    }

    /// Среднее число завершений в день (по дням, где было хотя бы одно).
    private static func average(records: [TrackerRecord]) -> Int {
        let cal = Calendar.current
        let days = Set(records.map { cal.startOfDay(for: $0.date) })
        return days.isEmpty ? 0 : records.count / days.count
    }
}
