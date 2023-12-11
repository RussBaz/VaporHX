import Vapor

public struct HXLanguageHeader {
    public struct Preference {
        public let value: Locale.LanguageCode
        public let priority: Double

        static func parse(directive: [HTTPHeaders.Directive]) -> Preference? {
            guard let first = directive.first, first.value != "q" else { return nil }
            let value = Locale.LanguageCode(String(first.value))
            var priority = 1.0

            if let last = directive.last, last.value == "q", let p = last.parameter {
                if let parameter = Double(p) {
                    priority = parameter
                }
            }

            return .init(value: value, priority: priority)
        }
    }

    public let preferences: [Preference]
    public let defautLanguageCode: Locale.LanguageCode

    static func parse(directives: [[HTTPHeaders.Directive]], lang: Locale.LanguageCode) -> HXLanguageHeader {
        .init(preferences: directives.compactMap(Preference.parse).sorted(), defautLanguageCode: lang)
    }

    public var prefered: Locale.LanguageCode {
        preferences.last?.value ?? defautLanguageCode
    }
}

extension HXLanguageHeader.Preference: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.priority < rhs.priority
    }
}
