import Foundation

extension DateFormatter {
    /// Parses ISO date strings like "2024-06-15" returned by the API.
    static let isoDate: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        return f
    }()

    /// Friendly display format: "Jun 15, 2024"
    static let display: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()
}

extension String {
    /// Converts an API date string ("yyyy-MM-dd") to a `Date`.
    var apiDate: Date? {
        DateFormatter.isoDate.date(from: self)
    }

    /// Returns a friendly string like "Jun 15" or "Overdue" for runout dates.
    var runoutDisplay: String {
        guard let date = apiDate else { return "—" }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        switch days {
        case ..<0:   return "Overdue"
        case 0:      return "Today"
        case 1:      return "Tomorrow"
        case 2...7:  return "In \(days)d"
        default:     return DateFormatter.display.string(from: date)
        }
    }

    /// True when the runout date is within 3 days (or past).
    var isRunoutSoon: Bool {
        guard let date = apiDate else { return false }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        return days <= 3
    }
}
