import Vapor

public struct HXPushUrlHeader {
    public enum HXPushType {
        case enable
        case disable
        case custom(String)
    }

    public let url: HXPushType

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
            resp.headers.replaceOrAdd(name: "HX-Push-Url", value: serialised)
        }
    }
}
