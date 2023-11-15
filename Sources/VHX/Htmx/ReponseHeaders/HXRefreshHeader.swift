import Vapor

public struct HXRefreshHeader: HXResponseHeaderAddable {
    public let value: Bool

    public func serialise() -> String {
        if value { "true" } else { "" }
    }

    public func add(to resp: Response) {
        if value {
            resp.headers.replaceOrAdd(name: "HX-Refresh", value: serialise())
        }
    }
}

public extension HXRefreshHeader {
    init() {
        value = true
    }
}
