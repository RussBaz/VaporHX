import Vapor

public struct HXReswapHeader: HXResponseHeaderAddable {
    public enum HXSwapType: String, RawRepresentable {
        case innerHTML, outerHTML, beforebegin, afterbegin, beforeend, afterend, delete, none
    }

    public enum HXDelayModifier {
        case minutes(UInt)
        case seconds(UInt)
        case milliSeconds(UInt)
    }

    public enum HXScrollSide: String, RawRepresentable {
        case top, bottom
    }

    public enum HXScrollModifier {
        case none
        case window(HXScrollSide)
        case selector(String, HXScrollSide)
        case element(HXScrollSide)
    }

    public let type: HXSwapType
    public let transition: Bool
    public let swap: HXDelayModifier?
    public let settle: HXDelayModifier?
    public let ignoreTitle: Bool
    public let scroll: HXScrollModifier?
    public let show: HXScrollModifier?
    public let focusScroll: Bool

    public func serialise() -> String {
        let transitionPart = if transition { " transition:true" } else { "" }
        let swapPart = if let swap { " swap:\(swap.serialise())" } else { "" }
        let settlePart = if let settle { " settle:\(settle.serialise())" } else { "" }
        let ignoreTitlePart = if ignoreTitle { " ignoreTitle:true" } else { "" }
        let scrollPart = if let scroll { " scroll:\(scroll.serialise())" } else { "" }
        let showPart = if let show { " show:\(show.serialise())" } else { "" }
        let focusScrollPart = if focusScroll { " focus-scroll:true" } else { "" }
        return "\(type)\(transitionPart)\(swapPart)\(settlePart)\(ignoreTitlePart)\(scrollPart)\(showPart)\(focusScrollPart)"
    }

    public func add(to resp: Response) {
        resp.headers.replaceOrAdd(name: "HX-Reswap", value: serialise())
    }
}

public extension HXReswapHeader.HXDelayModifier {
    func serialise() -> String {
        switch self {
        case let .minutes(value):
            "\(value)m"
        case let .seconds(value):
            "\(value)s"
        case let .milliSeconds(value):
            "\(value)ms"
        }
    }
}

public extension HXReswapHeader.HXScrollModifier {
    func serialise() -> String {
        switch self {
        case .none:
            "none"
        case let .element(side):
            "\(side)"
        case let .window(side):
            "window:\(side)"
        case let .selector(selector, side):
            "\(selector):\(side)"
        }
    }
}

public extension HXReswapHeader {
    init(_ type: HXSwapType, transition: Bool = false, swap: HXDelayModifier? = nil, settle: HXDelayModifier? = nil, ignoreTitle: Bool = false, scroll: HXScrollModifier? = nil, show: HXScrollModifier? = nil, focusScroll: Bool = false) {
        self.type = type
        self.transition = transition
        self.swap = swap
        self.settle = settle
        self.ignoreTitle = ignoreTitle
        self.scroll = scroll
        self.show = show
        self.focusScroll = focusScroll
    }

    func setTransition(_ newTransition: Bool) -> Self {
        .init(type: type, transition: newTransition, swap: swap, settle: settle, ignoreTitle: ignoreTitle, scroll: scroll, show: show, focusScroll: focusScroll)
    }

    func setSwap(_ newSwap: HXDelayModifier?) -> Self {
        .init(type: type, transition: transition, swap: newSwap, settle: settle, ignoreTitle: ignoreTitle, scroll: scroll, show: show, focusScroll: focusScroll)
    }

    func setSettle(_ newSettle: HXDelayModifier?) -> Self {
        .init(type: type, transition: transition, swap: swap, settle: newSettle, ignoreTitle: ignoreTitle, scroll: scroll, show: show, focusScroll: focusScroll)
    }

    func setIgnoreTitle(_ newIgnoreTitle: Bool) -> Self {
        .init(type: type, transition: transition, swap: swap, settle: settle, ignoreTitle: newIgnoreTitle, scroll: scroll, show: show, focusScroll: focusScroll)
    }

    func setScroll(_ newScroll: HXScrollModifier?) -> Self {
        .init(type: type, transition: transition, swap: swap, settle: settle, ignoreTitle: ignoreTitle, scroll: newScroll, show: show, focusScroll: focusScroll)
    }

    func setShow(_ newShow: HXScrollModifier?) -> Self {
        .init(type: type, transition: transition, swap: swap, settle: settle, ignoreTitle: ignoreTitle, scroll: scroll, show: newShow, focusScroll: focusScroll)
    }

    func setFocusScroll(_ newFocusScroll: Bool) -> Self {
        .init(type: type, transition: transition, swap: swap, settle: settle, ignoreTitle: ignoreTitle, scroll: scroll, show: show, focusScroll: newFocusScroll)
    }
}

extension HXReswapHeader: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        try container.encode(serialise())
    }
}
