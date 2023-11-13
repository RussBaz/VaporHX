import Vapor

public struct HXReselectHeader {
    public let value: String

    public func serialise() -> String {
        value
    }

    public func add(to resp: Response) {
        if !value.isEmpty {
            resp.headers.replaceOrAdd(name: "HX-Reselect", value: serialise())
        }
    }
}

public extension HXReselectHeader {
    init(_ value: String) {
        self.value = value
    }
}
