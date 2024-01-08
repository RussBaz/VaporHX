enum HXBasicLeafTemplate {}

extension HXBasicLeafTemplate {
    enum ParsedTemplate {
        case basic(String)
        case custom(template: String, slot: String?, value: String)
    }

    static func parseBasicTemplate(value: String) -> ParsedTemplate {
        enum State {
            case template
            case slot
            case value
            case error
        }

        if value.starts(with: "[") {
            var pos = value.index(after: value.startIndex)

            var templateEndPos: String.Index?
            var slotEndPos: String.Index?

            func more(state: State) -> State {
                switch state {
                case .template:
                    guard pos < value.endIndex else {
                        return .error
                    }

                    let c = value[pos]

                    if c == "]" {
                        templateEndPos = pos
                        return .value
                    } else if c == ":" {
                        templateEndPos = pos
                        return .slot
                    } else {
                        return .template
                    }
                case .slot:
                    guard pos < value.endIndex else {
                        return .error
                    }

                    let c = value[pos]

                    if c == "]" {
                        slotEndPos = pos
                        return .value
                    } else if c == ":" {
                        return .error
                    } else {
                        return .slot
                    }
                case .value:
                    return .value
                case .error:
                    return .error
                }
            }

            func parse(state: State) -> State {
                let next = more(state: state)
                pos = value.index(after: pos)

                switch next {
                case .template:
                    return parse(state: next)
                case .slot:
                    return parse(state: next)
                case .value:
                    return .value
                case .error:
                    return .error
                }
            }

            func scheduleParse() -> Bool {
                let result = parse(state: .template)

                guard result == .value else { return false }

                return true
            }

            guard scheduleParse() else { return .basic(value) }

            guard let templateEndPos else { return .basic(value) }

            let templateName = String(value[value.index(after: value.startIndex) ..< templateEndPos])

            if let slotEndPos {
                let slotName = String(value[value.index(after: templateEndPos) ..< slotEndPos])
                let remainder = String(value[value.index(after: slotEndPos) ..< value.endIndex])

                guard !templateName.isEmpty, !remainder.isEmpty, !slotName.isEmpty else { return .basic(value) }

                return .custom(template: templateName, slot: slotName, value: remainder)
            } else {
                let remainder = String(value[value.index(after: templateEndPos) ..< value.endIndex])

                guard !templateName.isEmpty, !remainder.isEmpty else { return .basic(value) }

                return .custom(template: templateName, slot: nil, value: remainder)
            }
        }

        return .basic(value)
    }

    static func prepareBasicTemplateBuilder(defaultBaseTemplate: String, defaultSlotName: String) -> PageTemplateBuilder {
        func templateBuilder(_ name: String) -> String {
            let result = parseBasicTemplate(value: name)

            switch result {
            case let .basic(value):
                return
                    """
                    #extend("\(defaultBaseTemplate)"): #export("\(defaultSlotName)"): #extend("\(value)") #endexport #endextend
                    """
            case let .custom(template, slot, value):
                return
                    """
                    #extend("\(template)"): #export("\(slot ?? defaultSlotName)"): #extend("\(value)") #endexport #endextend
                    """
            }
        }

        return templateBuilder
    }
}
