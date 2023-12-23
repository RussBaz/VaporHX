import Vapor

// Copy of the official Vapor Directive handler. It is internal and therefore I had to copy it
// Original source: https://github.com/vapor/vapor/blob/main/Sources/Vapor/HTTP/Headers/HTTPHeaders%2BDirective.swift
extension HTTPHeaders {
    struct Directive: Equatable, CustomStringConvertible {
        var value: Substring
        var parameter: Substring?

        var description: String {
            if let parameter {
                "Directive(value: \(value.debugDescription), parameter: \(parameter.debugDescription))"
            } else {
                "Directive(value: \(value.debugDescription))"
            }
        }

        init(value: String, parameter: String? = nil) {
            self.value = .init(value)
            self.parameter = parameter.flatMap { .init($0) }
        }

        init(value: Substring, parameter: Substring? = nil) {
            self.value = value
            self.parameter = parameter
        }
    }

    func parseDirectives(name: Name) -> [[Directive]] {
        let headers = self[name]
        var values: [[Directive]] = []
        let separatorCharacters = getSeparatorCharacters(for: name)
        for header in headers {
            var parser = DirectiveParser(string: header)
            while let directives = parser.nextDirectives(separatorCharacters: separatorCharacters) {
                values.append(directives)
            }
        }
        return values
    }

    private func getSeparatorCharacters(for headerName: Name) -> [Character] {
        switch headerName {
        // Headers with dates can't have comma as a separator
        case .setCookie, .ifModifiedSince, .date, .lastModified, .expires:
            [.semicolon]
        default: [.comma, .semicolon]
        }
    }

    mutating func serializeDirectives(_ directives: [[Directive]], name: Name) {
        let serializer = DirectiveSerializer(directives: directives)
        replaceOrAdd(name: name, value: serializer.serialize())
    }

    struct DirectiveParser {
        var current: Substring

        init(string: some StringProtocol) {
            current = .init(string)
        }

        mutating func nextDirectives(separatorCharacters: [Character] = [.comma, .semicolon]) -> [Directive]? {
            guard !current.isEmpty else {
                return nil
            }
            var directives: [Directive] = []
            while let directive = nextDirective(separatorCharacters: separatorCharacters) {
                directives.append(directive)
            }
            return directives
        }

        private mutating func nextDirective(separatorCharacters: [Character] = [.comma, .semicolon]) -> Directive? {
            popWhitespace()
            guard !current.isEmpty else {
                return nil
            }

            if current.first == .comma {
                pop()
                return nil
            }

            let value: Substring
            let parameter: Substring?
            if let equals = firstParameterToken() {
                value = pop(to: equals)
                pop()
                parameter = nextDirectiveValue(separatorCharacters: separatorCharacters)
            } else {
                value = nextDirectiveValue(separatorCharacters: separatorCharacters)
                parameter = nil
            }
            return .init(
                value: value.trimLinearWhitespace(),
                parameter: parameter?.trimLinearWhitespace()
                    .unescapingDoubleQuotes()
            )
        }

        private mutating func nextDirectiveValue(separatorCharacters: [Character]) -> Substring {
            let value: Substring
            popWhitespace()
            if current.first == .doubleQuote {
                pop()
                guard let nextDoubleQuote = firstUnescapedDoubleQuote() else {
                    return pop(to: current.endIndex)
                }
                value = pop(to: nextDoubleQuote).unescapingDoubleQuotes()
                pop()
                popWhitespace()
                if current.first == .semicolon {
                    pop()
                }
            } else if let separatorMatch = firstIndex(matchingAnyOf: separatorCharacters) {
                value = pop(to: separatorMatch.index)
                if separatorMatch.matchedCharacter == .semicolon {
                    pop()
                }
            } else {
                value = pop(to: current.endIndex)
            }
            return value
        }

        private mutating func popWhitespace() {
            if let nonWhitespace = current.firstIndex(where: { !$0.isLinearWhitespace }) {
                current = current[nonWhitespace...]
            } else {
                current = ""
            }
        }

        private mutating func pop() {
            current = current.dropFirst()
        }

        private mutating func pop(to index: Substring.Index) -> Substring {
            let value = current[..<index]
            current = current[index...]
            return value
        }

        private func firstParameterToken() -> Substring.Index? {
            for index in current.indices {
                let character = current[index]
                if character == .equals {
                    return index
                } else if !character.isTokenCharacter {
                    return nil
                }
            }
            return nil
        }

        /// Returns the first index matching any of the passed in Characters, nil if no match
        private func firstIndex(matchingAnyOf characters: [Character]) -> (index: Substring.Index, matchedCharacter: Character)? {
            guard characters.isEmpty == false else { return nil }

            for index in current.indices {
                let character = current[index]
                guard let matchedCharacter = characters.first(where: { $0 == character }) else { continue }

                return (index, matchedCharacter)
            }
            return nil
        }

        private func firstUnescapedDoubleQuote() -> Substring.Index? {
            var startIndex = current.startIndex
            var nextDoubleQuote: Substring.Index?
            while nextDoubleQuote == nil {
                guard let possibleDoubleQuote = current[startIndex...].firstIndex(of: "\"") else {
                    return nil
                }
                // Check if quote is escaped.
                if current.startIndex == possibleDoubleQuote || current[current.index(before: possibleDoubleQuote)] != "\\" {
                    nextDoubleQuote = possibleDoubleQuote
                } else if possibleDoubleQuote < current.endIndex {
                    startIndex = current.index(after: possibleDoubleQuote)
                } else {
                    return nil
                }
            }
            return nextDoubleQuote
        }
    }

    struct DirectiveSerializer {
        let directives: [[Directive]]

        init(directives: [[Directive]]) {
            self.directives = directives
        }

        func serialize() -> String {
            var main: [String] = []

            for directives in directives {
                var sub: [String] = []
                for directive in directives {
                    let string: String = if let parameter = directive.parameter {
                        "\(directive.value)=\"\(parameter.escapingDoubleQuotes())\""
                    } else {
                        .init(directive.value)
                    }
                    sub.append(string)
                }
                main.append(sub.joined(separator: "; "))
            }

            return main.joined(separator: ", ")
        }
    }
}

private extension Substring {
    /// Converts all `\"` to `"`.
    func unescapingDoubleQuotes() -> Substring {
        split(separator: "\\").reduce(into: "") { result, part in
            if result.isEmpty || part.first == "\"" {
                result += part
            } else {
                result += "\\" + part
            }
        }
    }

    /// Converts all `"` to `\"`.
    func escapingDoubleQuotes() -> String {
        split(separator: "\"").joined(separator: "\\\"")
    }
}

private extension Character {
    static var doubleQuote: Self {
        .init(Unicode.Scalar(0x22))
    }

    static var semicolon: Self {
        .init(";")
    }

    static var equals: Self {
        .init("=")
    }

    static var comma: Self {
        .init(",")
    }

    static var space: Self {
        .init(" ")
    }

    /// The characters defined in RFC2616.
    ///
    /// Description from [RFC2616](https://tools.ietf.org/html/rfc2616):
    ///
    /// separators     = "(" | ")" | "<" | ">" | "@"
    ///                | "," | ";" | ":" | "\" | <">
    ///                | "/" | "[" | "]" | "?" | "="
    ///                | "{" | "}" | SP | HT
    static var separators: [Self] {
        ["(", ")", "<", ">", "@", ",", ":", ";", "\\", "\"", "/", "[", "]", "?", "=", "{", "}", " ", "\t"]
    }

    /// Check if this is valid character for token.
    ///
    /// Description from [RFC2616](]https://tools.ietf.org/html/rfc2616):
    ///
    /// token          = 1*<any CHAR except CTLs or separators>
    /// CHAR           = <any US-ASCII character (octets 0 - 127)>
    /// CTL            = <any US-ASCII control character
    ///                  (octets 0 - 31) and DEL (127)>
    var isTokenCharacter: Bool {
        guard let asciiValue else {
            return false
        }
        guard asciiValue > 31, asciiValue != 127 else {
            return false
        }
        return !Self.separators.contains(self)
    }
}

private extension Character {
    var isLinearWhitespace: Bool {
        self == " " || self == "\t"
    }
}

private extension Substring {
    func trimLinearWhitespace() -> Substring {
        var me = self
        while me.first?.isLinearWhitespace == .some(true) {
            me = me.dropFirst()
        }
        while me.last?.isLinearWhitespace == .some(true) {
            me = me.dropLast()
        }
        return me
    }
}

public extension HTTPHeaders {
    func language(fallback lang: String) -> HXLanguageHeader {
        HXLanguageHeader.parse(directives: parseDirectives(name: .acceptLanguage), lang: lang)
    }
}
