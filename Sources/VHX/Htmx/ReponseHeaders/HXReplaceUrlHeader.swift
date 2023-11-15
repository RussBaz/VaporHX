import Vapor

public struct HXReplaceUrlHeader: HXResponseHeaderAddable {
    public enum HXReplaceType {
        case disable
        case enable(String)
    }

    public let url: HXReplaceType

    public func serialise() -> String {
        switch url {
        case .disable:
            "false"
        case let .enable(custom):
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
    init(_ location: String) {
        url = .enable(location)
    }

    static func disabled() -> Self {
        .init(url: .disable)
    }
}
