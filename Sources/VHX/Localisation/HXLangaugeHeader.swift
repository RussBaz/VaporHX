import Vapor

public struct HXLanguageHeader {
    struct Preference {
        let value: Locale.LanguageCode
        let priority: Double

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

    let preferences: [Preference]

    static func parse(directives: [[HTTPHeaders.Directive]]) -> HXLanguageHeader {
        .init(preferences: directives.compactMap(Preference.parse).sorted())
    }

    var prefered: Locale.LanguageCode {
        preferences.last?.value ?? Locale.current.language.languageCode ?? Locale.LanguageCode(stringLiteral: "en")
    }
}

extension HXLanguageHeader.Preference: Comparable {
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.priority < rhs.priority
    }
}
