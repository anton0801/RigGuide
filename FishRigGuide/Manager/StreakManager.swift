import Foundation
import Combine

// MARK: - Streak Manager
class StreakManager: ObservableObject {
    static let shared = StreakManager()

    // MARK: - Published State
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var totalDaysUsed: Int = 0
    @Published var lastOpenDate: Date? = nil
    @Published var isNewStreakRecord: Bool = false

    // MARK: - UserDefaults Keys
    private enum Keys {
        static let currentStreak    = "streak_current"
        static let longestStreak    = "streak_longest"
        static let totalDaysUsed    = "streak_totalDays"
        static let lastOpenDate     = "streak_lastOpenDate"
        static let firstOpenDate    = "streak_firstOpenDate"
        static let openDates        = "streak_openDates"
        static let weeklyActivity   = "streak_weeklyActivity"
    }

    private let defaults = UserDefaults.standard
    private let calendar = Calendar.current

    private init() {
        load()
        recordTodayOpen()
    }

    // MARK: - Load persisted data
    private func load() {
        currentStreak = defaults.integer(forKey: Keys.currentStreak)
        longestStreak = defaults.integer(forKey: Keys.longestStreak)
        totalDaysUsed = defaults.integer(forKey: Keys.totalDaysUsed)

        if let ts = defaults.object(forKey: Keys.lastOpenDate) as? Date {
            lastOpenDate = ts
        }
    }

    // MARK: - Record today's visit
    func recordTodayOpen() {
        let today = calendar.startOfDay(for: Date())

        // --- Check if already recorded today ---
        if let last = lastOpenDate {
            let lastDay = calendar.startOfDay(for: last)
            if calendar.isDate(lastDay, inSameDayAs: today) {
                return // already counted today
            }

            let diff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0

            if diff == 1 {
                // Consecutive day
                currentStreak += 1
            } else if diff > 1 {
                // Streak broken
                currentStreak = 1
            }
        } else {
            // First ever open
            currentStreak = 1
            defaults.set(today, forKey: Keys.firstOpenDate)
        }

        totalDaysUsed += 1
        lastOpenDate = Date()

        // Update longest
        let previousLongest = longestStreak
        if currentStreak > longestStreak {
            longestStreak = currentStreak
            isNewStreakRecord = currentStreak > previousLongest && previousLongest > 0
        }

        // Save open dates array for activity graph
        var dates = openDates
        dates.append(today)
        let encoded = try? JSONEncoder().encode(dates)
        defaults.set(encoded, forKey: Keys.openDates)

        // Persist
        defaults.set(currentStreak, forKey: Keys.currentStreak)
        defaults.set(longestStreak, forKey: Keys.longestStreak)
        defaults.set(totalDaysUsed, forKey: Keys.totalDaysUsed)
        defaults.set(lastOpenDate, forKey: Keys.lastOpenDate)
    }

    // MARK: - Open dates history
    var openDates: [Date] {
        guard let data = defaults.data(forKey: Keys.openDates),
              let decoded = try? JSONDecoder().decode([Date].self, from: data) else {
            return []
        }
        return decoded
    }

    // MARK: - First open date
    var firstOpenDate: Date {
        defaults.object(forKey: Keys.firstOpenDate) as? Date ?? Date()
    }

    // MARK: - Last 7 days activity (for mini chart)
    var last7DaysActivity: [Bool] {
        let today = calendar.startOfDay(for: Date())
        let dates = Set(openDates.map { calendar.startOfDay(for: $0) })
        return (0..<7).reversed().map { offset in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { return false }
            return dates.contains(day)
        }
    }

    // MARK: - Streak flame level
    var flameLevel: FlameLevel {
        switch currentStreak {
        case 0...2:   return .cold
        case 3...6:   return .warm
        case 7...13:  return .hot
        default:      return .blazing
        }
    }

    enum FlameLevel {
        case cold, warm, hot, blazing
        var color: String {
            switch self {
            case .cold:    return "9CB6C9"
            case .warm:    return "4FC3F7"
            case .hot:     return "FFB74D"
            case .blazing: return "FF6B6B"
            }
        }
        var icon: String {
            switch self {
            case .cold:    return "snowflake"
            case .warm:    return "flame"
            case .hot:     return "flame.fill"
            case .blazing: return "flame.fill"
            }
        }
        var label: String {
            switch self {
            case .cold:    return "Start fishing!"
            case .warm:    return "Getting warm"
            case .hot:     return "On fire!"
            case .blazing: return "Legendary angler"
            }
        }
    }
}
