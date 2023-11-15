import Vapor

public struct HXPushUrlHeader: HXResponseHeaderAddable {
    public enum HXPushType {
        case disable
        case enable(String)
    }

    public let url: HXPushType

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
            resp.headers.replaceOrAdd(name: "HX-Push-Url", value: serialised)
        }
    }
}

public extension HXPushUrlHeader {
    init(_ value: String) {
        url = .enable(value)
    }

    static func disabled() -> Self {
        .init(url: .disable)
    }
}
