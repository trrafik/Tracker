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
        let cal = Calendar.current
        let days = Set(records.map { cal.startOfDay(for: $0.date) }).sorted()
        guard !days.isEmpty else { return 0 }
        var maxStreak = 1
        var current = 1
        for i in 1..<days.count {
            let nextExpected = cal.date(byAdding: .day, value: 1, to: days[i - 1])
            if let next = nextExpected, cal.isDate(days[i], inSameDayAs: next) {
                current += 1
            } else {
                maxStreak = max(maxStreak, current)
                current = 1
            }
        }
        return max(maxStreak, current)
    }

    /// Дни, в которые все запланированные на этот день трекеры были завершены.
    private static func idealDays(records: [TrackerRecord], trackers: [Tracker]) -> Int {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        func weekday(for date: Date) -> Tracker.Weekday {
            let w = cal.component(.weekday, from: date)
            return w == 1 ? .sunday : (Tracker.Weekday(rawValue: w - 1) ?? .monday)
        }
        let byDay: [Date: Set<UUID>] = Dictionary(grouping: records) { cal.startOfDay(for: $0.date) }
            .mapValues { Set($0.map(\.trackerId)) }
        return byDay.filter { day, completedIds in
            guard day <= today else { return false }
            let wd = weekday(for: day)
            let scheduled = Set(trackers.filter { $0.schedule.isEmpty || $0.schedule.contains(wd) }.map(\.id))
            return !scheduled.isEmpty && scheduled.isSubset(of: completedIds)
        }.count
    }

    /// Среднее число завершений в день (по дням, где было хотя бы одно).
    private static func average(records: [TrackerRecord]) -> Int {
        let cal = Calendar.current
        let days = Set(records.map { cal.startOfDay(for: $0.date) })
        return days.isEmpty ? 0 : records.count / days.count
    }
}
