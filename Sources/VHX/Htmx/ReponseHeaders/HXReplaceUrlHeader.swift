import Vapor

public struct HXReplaceUrlHeader {
    public enum HXReplaceType {
        case enable
        case disable
        case custom(String)
    }

    let url: HXReplaceType

    func serialise() -> String {
        switch url {
        case .enable:
            "true"
        case .disable:
            "false"
        case let .custom(custom):
            "\(custom)"
        }
    }

    func add(to resp: Response) {
        let serialised = serialise()

        if !serialised.isEmpty {
            resp.headers.replaceOrAdd(name: "HX-Replace-Url", value: serialised)
        }
    }
}

extension HXReplaceUrlHeader {
    init() {
        url = .enable
    }
}
