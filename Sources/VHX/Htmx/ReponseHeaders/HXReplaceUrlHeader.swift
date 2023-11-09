import Vapor

public struct HXReplaceUrlHeader {
    public enum HXReplaceType {
        case enable
        case disable
        case custom(String)
    }

    public let url: HXReplaceType

    public func serialise() -> String {
        switch url {
        case .enable:
            "true"
        case .disable:
            "false"
        case let .custom(custom):
            "\(custom)"
        }
    }

    public func add(to resp: Response) {
        let serialised = serialise()

        if !serialised.isEmpty {
            resp.headers.replaceOrAdd(name: "HX-Replace-Url", value: serialised)
        }
    }
}

public extension HXReplaceUrlHeader {
    init() {
        url = .enable
    }
}
