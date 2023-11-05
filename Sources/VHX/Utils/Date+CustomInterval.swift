import Vapor

public extension Date {
    func addingCustomInterval(days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) -> Date {
        var interval = days * 24 * 60 * 60
        interval = interval + hours * 60 * 60
        interval = interval + minutes * 60
        interval = interval + seconds
        return addingTimeInterval(TimeInterval(interval))
    }
}
