import Vapor

public struct HXRedirectHeader {
    public let location: String

    public func serialise() -> String {
        location
    }

    public func add(to resp: Response) {
        if !location.isEmpty {
            resp.headers.replaceOrAdd(name: "HX-Redirect", value: serialise())
        }
    }
}

public extension HXRedirectHeader {
    init(_ url: String) {
        location = url
    }
}
