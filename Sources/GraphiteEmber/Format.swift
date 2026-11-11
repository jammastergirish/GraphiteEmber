import Foundation

/// Time and date labels shared by the apps. Apps add their own formats in an
/// `extension Format`.
public enum Format {
    /// When something happened, relative to `now`:
    /// "Today 19:53", "Yesterday 08:12", "Mon 9 Nov 14:03", "9 Nov 2025 14:03".
    public static func when(_ date: Date, now: Date = Date()) -> String {
        let cal = Calendar.current
        let time = timeFmt.string(from: date)
        if cal.isDate(date, inSameDayAs: now) { return "Today \(time)" }
        if let yesterday = cal.date(byAdding: .day, value: -1, to: now), cal.isDate(date, inSameDayAs: yesterday) {
            return "Yesterday \(time)"
        }
        if cal.isDate(date, equalTo: now, toGranularity: .year) { return "\(dayFmt.string(from: date)) \(time)" }
        return "\(yearFmt.string(from: date)) \(time)"
    }

    /// Running timer: "00:12:34".
    public static func clock(_ t: TimeInterval) -> String {
        let s = Int(t)
        return String(format: "%02d:%02d:%02d", s / 3600, (s / 60) % 60, s % 60)
    }

    /// Length of a recording: "0:05", "12:34", "1:02:03".
    public static func length(_ t: TimeInterval) -> String {
        let s = Int(t.rounded())
        return s >= 3600
            ? String(format: "%d:%02d:%02d", s / 3600, (s / 60) % 60, s % 60)
            : String(format: "%d:%02d", s / 60, s % 60)
    }

    /// A DateFormatter with a fixed pattern.
    public static func formatter(_ pattern: String) -> DateFormatter {
        let f = DateFormatter()
        f.dateFormat = pattern
        return f
    }

    private static let timeFmt = formatter("HH:mm")
    private static let dayFmt = formatter("EEE d MMM")
    private static let yearFmt = formatter("d MMM yyyy")
}
